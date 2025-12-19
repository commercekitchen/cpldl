# frozen_string_literal: true

require "zip"
require "stringio"

class UnzipStorylineJob < ApplicationJob
  queue_as :default

  # Retry transient failures (network/S3). Tune attempts + backoff to your tolerance.
  retry_on(
    Aws::S3::Errors::ServiceError,
    Timeout::Error,
    Errno::ECONNRESET,
    Errno::ETIMEDOUT,
    SocketError,
    wait: :exponentially_longer,
    attempts: 10
  )

  class InvalidStorylineError < StandardError; end

  # Don’t retry forever on deterministic failures.
  discard_on ActiveRecord::RecordNotFound
  discard_on UnzipStorylineJob::InvalidStorylineError

  def perform(lesson_id, purge_destination: true, refuse_child_lessons: true)
    lesson = Lesson.find(lesson_id)

    begin
      unzip!(lesson, purge_destination:, refuse_child_lessons:)
      clear_unzip_error!(lesson)
    rescue InvalidStorylineError => e
      record_unzip_error!(lesson, e)
      raise # re-raise with original backtrace
    end
  end

  private

  def unzip!(lesson, purge_destination:, refuse_child_lessons:)
    if refuse_child_lessons && lesson.parent_id.present?
      raise InvalidStorylineError, "Refusing to unzip storyline for child lesson #{lesson.id} (parent #{lesson.parent_id})"
    end

    blob = lesson.story_line_archive&.blob
    return unless blob

    root_path = lesson.storyline_root_path
    raise InvalidStorylineError, "Missing storyline_root_path for Lesson #{lesson.id}" if root_path.blank?

    bucket = Rails.configuration.s3_bucket_name
    s3     = Aws::S3::Client.new

    # Make the operation idempotent (re-upload yields exact contents)
    delete_prefix!(s3, bucket: bucket, prefix: "#{root_path}/") if purge_destination

    # Avoid loading entire zip into memory
    blob.open(tmpdir: Dir.tmpdir) do |file|
      Zip::File.open(file.path) do |zip|
        zip.each do |entry|
          next if entry.name_is_directory?
          next if skip_entry?(entry.name)

          safe_rel_path = sanitize_zip_entry_path!(entry.name)
          key = "#{root_path}/#{safe_rel_path}"

          body_io, content_type = build_body_and_content_type(entry)

          # Upload; body can be IO (streamed) or StringIO (for patched file)
          s3.put_object(
            bucket: bucket,
            key: key,
            body: body_io,
            acl: "private",
            content_type: content_type,
            content_disposition: "inline"
            # Optional: cache headers (often helpful for Storyline assets behind CDN)
            # cache_control: "public, max-age=31536000, immutable"
          )
        end
      end
    end
  rescue Zip::Error, Zip::CentralDirectoryError => e
    # Deterministic “bad zip”; don’t endlessly retry unless you want to.
    raise InvalidStorylineError, "Unable to unzip storyline archive for lesson #{lesson_id}: #{e.class}: #{e.message}"
  end

  # Mirror the Lambda “fixLessonJs” behavior
  def patch_user_js(bytes)
    file_string = bytes.to_s

    old_event_string = "window.parent.sendLessonCompletedEvent()"
    new_event_string = 'window.parent.postMessage("lesson_completed", "*")'
    dlc_transition_string = "getDLCTransition('lesson')"

    patched = file_string
      .gsub(old_event_string, new_event_string)
      .gsub(dlc_transition_string, new_event_string)

    patched
  end

  def build_body_and_content_type(entry)
    name = entry.name

    if name.end_with?("user.js")
      original = entry.get_input_stream.read
      patched  = patch_user_js(original)
      io = StringIO.new(patched)
      io.rewind
      [io, "application/javascript"]
    else
      # Stream entry content rather than reading entire file into memory.
      # Aws SDK will read from IO; Zip stream is fine for put_object.
      io = entry.get_input_stream

      content_type = Marcel::MimeType.for(
        name: name,
        extension: File.extname(name),
        declared_type: "application/octet-stream"
      ) || "application/octet-stream"

      [io, content_type]
    end
  end

  # Prevent zip-slip (../../etc/passwd) and normalize odd paths.
  def sanitize_zip_entry_path!(entry_name)
    # Zip can include backslashes; normalize to forward slash.
    normalized = entry_name.tr("\\", "/")

    # Remove leading slashes
    normalized = normalized.sub(%r{\A/+}, "")

    # Resolve ./ and ../
    parts = []
    normalized.split("/").each do |part|
      next if part.empty? || part == "."
      if part == ".."
        parts.pop
      else
        parts << part
      end
    end

    safe = parts.join("/")
    raise InvalidStorylineError, "Invalid zip entry path: #{entry_name.inspect}" if safe.blank?

    safe
  end

  def skip_entry?(name)
    # Common junk in zips created on macOS or by some build tools
    return true if name.start_with?("__MACOSX/")
    return true if name.end_with?(".DS_Store")
    return true if name.end_with?("Thumbs.db")

    false
  end

  # Deletes all objects under a prefix. This makes the job idempotent.
  # For large packages, this can be a lot of list+delete calls; still usually worth it.
  def delete_prefix!(s3, bucket:, prefix:)
    continuation_token = nil

    loop do
      resp = s3.list_objects_v2(
        bucket: bucket,
        prefix: prefix,
        continuation_token: continuation_token
      )

      keys = resp.contents.map { |o| { key: o.key } }
      if keys.any?
        # S3 delete_objects max is 1000 keys per request
        keys.each_slice(1000) do |slice|
          s3.delete_objects(bucket: bucket, delete: { objects: slice, quiet: true })
        end
      end

      break unless resp.is_truncated
      continuation_token = resp.next_continuation_token
    end
  end

  def record_unzip_error!(lesson, exception)
    # Keep it short-ish so you don’t blow up a text column with huge messages.
    msg = "#{exception.class}: #{exception.message}".truncate(10_000)

    lesson.update_columns(
      storyline_unzip_error: msg,
      storyline_unzip_failed_at: Time.current,
      updated_at: Time.current
    )
  rescue => write_err
    # Never hide the real failure if writing the error fails
    Rails.logger.error(
      "Failed to persist storyline unzip error for Lesson #{lesson.id}: #{write_err.class}: #{write_err.message}"
    )
  end

  def clear_unzip_error!(lesson)
    lesson.update_columns(
      storyline_unzip_error: nil,
      storyline_unzip_failed_at: nil,
      updated_at: Time.current
    )
  rescue => e
    Rails.logger.warn(
      "Failed to clear storyline unzip error for Lesson #{lesson.id}: #{e.class}: #{e.message}"
    )
  end
end
