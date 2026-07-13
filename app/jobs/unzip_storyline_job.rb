# frozen_string_literal: true

require "zip"
require "stringio"

class UnzipStorylineJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  # Not available in Rails 5
  # Retry transient failures (network/S3). Tune attempts + backoff to your tolerance.
  # retry_on(
  #   Aws::S3::Errors::ServiceError,
  #   Timeout::Error,
  #   Errno::ECONNRESET,
  #   Errno::ETIMEDOUT,
  #   SocketError,
  #   wait: :exponentially_longer,
  #   attempts: 10
  # )

  class InvalidStorylineError < StandardError; end

  # Don’t retry forever on deterministic failures.
  discard_on ActiveRecord::RecordNotFound
  discard_on UnzipStorylineJob::InvalidStorylineError

  def perform(lesson_id, purge_destination: true, refuse_child_lessons: true)
    Rails.logger.info(
      "UnzipStorylineJob started for Lesson #{lesson_id}, purge_destination=#{purge_destination}, refuse_child_lessons=#{refuse_child_lessons}"
    )
    lesson = Lesson.find(lesson_id)

    mark_processing!(lesson)

    begin
      unzip!(lesson, purge_destination: purge_destination, refuse_child_lessons: refuse_child_lessons)
      mark_complete!(lesson)
      clear_unzip_error!(lesson)
    rescue InvalidStorylineError => e
      mark_failed!(lesson, e)
      Rails.logger.error(
        "Failed to unzip storyline for Lesson #{lesson.id}: #{e.message}"
      )
      raise # re-raise with original backtrace
    end
  end

  private

  def unzip!(lesson, purge_destination:, refuse_child_lessons:)
    if refuse_child_lessons && lesson.parent_id.present?
      raise InvalidStorylineError, "Refusing to unzip storyline for child lesson #{lesson.id} (parent #{lesson.parent_id})"
    end

    unless lesson.story_line_archive.attached?
      raise InvalidStorylineError, "No story_line_archive attached for Lesson #{lesson.id}"
    end

    blob = lesson.story_line_archive.blob

    root_path = lesson.storyline_root_path
    raise InvalidStorylineError, "Missing storyline_root_path for Lesson #{lesson.id}" if root_path.blank?

    # storyline_root_path is also used as a URL path (leading slash required there);
    # S3 keys should not start with "/", or they end up stored under a hidden
    # empty-name prefix instead of the "storylines/..." path everything else expects.
    root_path = root_path.sub(%r{\A/+}, "")

    bucket = Rails.configuration.unzipped_lessons_bucket
    s3     = Aws::S3::Client.new

    delete_prefix!(s3, bucket: bucket, prefix: "#{root_path}/") if purge_destination

    # TODO: After rails 7 upgrade, use ActiveStorage::Blob#open with a block.
    # Rails 5.2: ActiveStorage::Blob#open is private; use download -> Tempfile instead.
    Tempfile.create(["storyline-#{lesson.id}-", ".zip"], Dir.tmpdir) do |tmp|
      tmp.binmode

      begin
        # This reads the blob into memory; if your zips get huge, we can switch to a streaming download,
        # but for typical Storyline packages this is usually acceptable.
        tmp.write(blob.download)
        tmp.flush
        tmp.rewind

        Zip::File.open(tmp.path) do |zip|
          wrapping_dir = common_wrapping_dir(zip)

          zip.each do |entry|
            next if entry.name_is_directory?
            next if skip_entry?(entry.name)

            safe_rel_path = sanitize_zip_entry_path!(entry.name, strip_leading_dir: wrapping_dir)
            key = "#{root_path}/#{safe_rel_path}"

            build_body_content_type_and_length(entry) do |io, content_type, length|
              s3.put_object(
                bucket: bucket,
                key: key,
                body: io,                 # <- rewindable file
                content_length: length,   # <- explicit
                content_type: content_type,
                content_disposition: "inline"
              )
            end
          end
        end
      rescue Zip::Error, Zlib::Error => e
        raise InvalidStorylineError,
              "Unable to unzip storyline archive for lesson #{lesson.id}: #{e.class}: #{e.message}"
      ensure
        # Ensure we don't leave a partial file around if something goes sideways.
        tmp.close! rescue nil
      end
    end
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

  def build_body_content_type_and_length(entry)
    name = entry.name

    content_type =
      if name.end_with?("user.js")
        "application/javascript"
      else
        Marcel::MimeType.for(
          name: name,
          extension: File.extname(name),
          declared_type: "application/octet-stream"
        ) || "application/octet-stream"
      end

    Tempfile.create(["storyline-", File.extname(name)], Dir.tmpdir) do |tmp|
      tmp.binmode

      if name.end_with?("user.js")
        patched = patch_user_js(entry.get_input_stream.read)
        tmp.write(patched)
      else
        # stream zip entry -> tempfile
        IO.copy_stream(entry.get_input_stream, tmp)
      end

      tmp.flush
      tmp.rewind

      yield tmp, content_type, tmp.size
    end
  end

  # Prevent zip-slip (../../etc/passwd) and normalize odd paths.
  def sanitize_zip_entry_path!(entry_name, strip_leading_dir: nil)
    parts = resolve_zip_entry_parts(entry_name)
    parts = parts[1..] if strip_leading_dir && parts.first == strip_leading_dir

    safe = parts.join("/")
    raise InvalidStorylineError, "Invalid zip entry path: #{entry_name.inspect}" if safe.blank?

    safe
  end

  def resolve_zip_entry_parts(entry_name)
    # Zip can include backslashes; normalize to forward slash, and strip leading slashes.
    normalized = normalize_zip_entry_encoding(entry_name).tr("\\", "/").sub(%r{\A/+}, "")

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

    parts
  end

  # Some Storyline exports zip the *folder* rather than its contents, so every
  # entry is nested under a single top-level directory (often matching the
  # archive's own filename, which we already use to build root_path). Detect
  # that shared wrapping folder so we can strip it and avoid doubling it up
  # in the S3 key, e.g. ".../<dir>/<dir>/story.html" instead of ".../<dir>/story.html".
  def common_wrapping_dir(zip)
    entries = zip.entries.reject { |e| e.name_is_directory? || skip_entry?(e.name) }
    return nil if entries.empty?

    segments = entries.map { |e| resolve_zip_entry_parts(e.name) }
    return nil if segments.any? { |parts| parts.size <= 1 }

    top_level_dirs = segments.map(&:first).uniq
    return nil unless top_level_dirs.size == 1

    top_level_dirs.first
  end

  # rubyzip returns entry names as raw bytes tagged ASCII-8BIT whenever the
  # archive doesn't set the zip "language encoding flag" (EFS bit) — common
  # with zips built by older/Windows tools — even though the bytes are
  # actually a valid text encoding. The AWS SDK later calls String#encode on
  # the S3 key and raises Encoding::UndefinedConversionError if it's still
  # tagged ASCII-8BIT, so we have to re-tag/transcode it to UTF-8 up front.
  def normalize_zip_entry_encoding(name)
    utf8_name = name.dup.force_encoding(Encoding::UTF_8)
    return utf8_name if utf8_name.valid_encoding?

    name.dup.force_encoding(Encoding::Windows_1252).encode(Encoding::UTF_8)
  rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError
    name.dup.force_encoding(Encoding::ASCII_8BIT).encode(
      Encoding::UTF_8, invalid: :replace, undef: :replace, replace: "_"
    )
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

  def mark_processing!(lesson)
    return unless lesson.respond_to?(:storyline_unzip_status=)
    lesson.update_columns(storyline_unzip_status: Lesson.storyline_unzip_statuses[:processing], updated_at: Time.current)
  end

  def mark_complete!(lesson)
    return unless lesson.respond_to?(:storyline_unzip_status=)
    lesson.update_columns(storyline_unzip_status: Lesson.storyline_unzip_statuses[:complete], updated_at: Time.current)
  end

  def mark_failed!(lesson, exception)
    record_unzip_error!(lesson, exception)
    return unless lesson.respond_to?(:storyline_unzip_status=)
    lesson.update_columns(storyline_unzip_status: Lesson.storyline_unzip_statuses[:failed], updated_at: Time.current)
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
