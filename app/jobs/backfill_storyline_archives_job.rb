require "tempfile"
require "aws-sdk-s3"
require "securerandom"

class BackfillStorylineArchivesJob < ApplicationJob
  class MissingSourceObjectError < StandardError; end

  queue_as :maintenance

  retry_on StandardError, wait: :exponentially_longer, attempts: 3
  discard_on ActiveRecord::RecordNotFound
  discard_on MissingSourceObjectError

  def perform(args = {})
    args = args.with_indifferent_access

    start_id   = args[:start_id]
    batch_size = (args[:batch_size] || 200).to_i
    verbose    = !!args[:verbose]

    run_id = args[:run_id].presence || SecureRandom.hex(6)

    scope = Lesson.order(:id)
    scope = scope.where("id >= ?", start_id) if start_id.present?

    batch = scope.limit(batch_size).to_a
    return if batch.empty?

    stats = Hash.new(0)
    stats[:batch_size] = batch.size

    Rails.logger.info("[BackfillStorylineArchivesJob][run=#{run_id}] Starting batch start_id=#{start_id.inspect} size=#{batch.size}")

    batch.each do |lesson|
      stats[:examined] += 1

      begin
        skip_reason = skip_reason_for(lesson)
        if skip_reason
          stats[:"skipped_#{skip_reason}"] += 1
          Rails.logger.info("[BackfillStorylineArchivesJob][run=#{run_id}] Lesson #{lesson.id} skipped=#{skip_reason}") if verbose
          next
        end

        stats[:attempted] += 1

        result = migrate_one!(lesson, run_id: run_id)

        if result == :missing_source
          stats[:missing_source] += 1
          next
        end

        # Verify attach actually stuck
        lesson.reload
        unless lesson.story_line_archive.attached?
          raise "Attach did not persist (story_line_archive not attached after reload)"
        end

        # Optional sanity: ensure blob exists and has content
        blob = lesson.story_line_archive.blob
        if blob.nil? || blob.byte_size.to_i <= 0
          raise "Attach persisted but blob missing/empty (blob_id=#{blob&.id.inspect} byte_size=#{blob&.byte_size.inspect})"
        end

        stats[:succeeded] += 1
        Rails.logger.info("[BackfillStorylineArchivesJob][run=#{run_id}] Lesson #{lesson.id} attached blob_id=#{blob.id} bytes=#{blob.byte_size}") if verbose

        if lesson.respond_to?(:migrated_to_active_storage_at)
          lesson.update_columns(migrated_to_active_storage_at: Time.current, updated_at: Time.current)
        end
      rescue MissingSourceObjectError => e
        # You already discard_on this, but rescuing here makes it per-lesson instead of nuking the batch.
        mark_missing_source!(lesson, e.message)
        stats[:missing_source] += 1
      rescue => e
        stats[:failed] += 1
        mark_failed!(lesson, e, run_id: run_id)
        Rails.logger.error("[BackfillStorylineArchivesJob][run=#{run_id}] Lesson #{lesson.id} FAILED #{e.class}: #{e.message}\n#{e.backtrace&.first(15)&.join("\n")}")
        # Continue to next lesson; don’t let one poison the whole batch.
      end
    end

    Rails.logger.info("[BackfillStorylineArchivesJob][run=#{run_id}] Batch done start_id=#{start_id.inspect} last_id=#{batch.last.id} stats=#{stats.inspect}")

    self.class.perform_later(start_id: batch.last.id + 1, batch_size: batch_size, run_id: run_id, verbose: verbose)
  end

  private

  def skip_reason_for(lesson)
    if lesson.respond_to?(:migrated_to_active_storage_at) && lesson.migrated_to_active_storage_at.present?
      return :already_migrated
    end

    if lesson.story_line_archive.attached?
      return :already_attached
    end

    unless lesson.respond_to?(:story_line)
      return :no_story_line_method
    end

    # This is ambiguous depending on Paperclip storage backend. Keep it, but make it visible.
    unless lesson.story_line.exists?
      return :paperclip_missing
    end

    nil
  end

  def migrate_one!(lesson, run_id:)
    filename = lesson.story_line_file_name.to_s
    filename = "storyline_#{lesson.id}.zip" if filename.blank?
    content_type = lesson.story_line_content_type.presence || "application/zip"

    Tempfile.create(["storyline-", File.extname(filename)]) do |tmp|
      tmp.binmode

      begin
        if Rails.application.config.s3_enabled
          bytes = download_paperclip_from_s3_to!(lesson.story_line, tmp)
        else
          bytes = download_paperclip_from_disk_to!(lesson.story_line, tmp)
        end
      rescue MissingSourceObjectError => e
        mark_missing_source!(lesson, e.message)
        Rails.logger.warn("[BackfillStorylineArchivesJob][run=#{run_id}] Lesson #{lesson.id} missing_source #{e.message}")
        return :missing_source
      end

      tmp.rewind

      lesson.story_line_archive.attach(
        io: tmp,
        filename: filename,
        content_type: content_type
      )

      # Note: attach may enqueue analysis; it should still create blob+attachment synchronously.
      # Verification happens in caller after reload.

      bytes
    end
  end

  def download_paperclip_from_disk_to!(paperclip_attachment, tmp)
    path = paperclip_attachment.path
    raise MissingSourceObjectError, "Local file missing (path=#{path})" unless path.present? && File.exist?(path)

    File.open(path, "rb") do |f|
      IO.copy_stream(f, tmp)
    end
  end

  def download_paperclip_from_s3_to!(paperclip_attachment, tmp)
    s3_obj = paperclip_attachment.s3_object
    bucket = s3_obj.bucket_name
    key    = s3_obj.key

    s3 = Aws::S3::Client.new(region: Rails.application.config.s3_region)

    bytes = 0
    begin
      s3.get_object(bucket: bucket, key: key) do |chunk|
        bytes += chunk.bytesize
        tmp.write(chunk)
      end
    rescue Aws::S3::Errors::NoSuchKey, Aws::S3::Errors::NotFound
      raise MissingSourceObjectError, "S3 object missing (bucket=#{bucket} key=#{key})"
    end

    bytes
  end

  def mark_failed!(lesson, err, run_id:)
    msg =
      +"Backfill failed [run=#{run_id}] #{err.class}: #{err.message}\n" \
      "lesson_id=#{lesson.id}\n" \
      "#{(err.backtrace || []).first(30).join("\n")}"

    attrs = {
      storyline_unzip_error: msg.truncate(10_000),
      storyline_unzip_failed_at: Time.current,
      updated_at: Time.current
    }

    if lesson.respond_to?(:storyline_unzip_status) && Lesson.respond_to?(:storyline_unzip_statuses)
      attrs[:storyline_unzip_status] = Lesson.storyline_unzip_statuses[:failed]
    end

    lesson.update_columns(attrs)
  rescue => write_err
    Rails.logger.error("[BackfillStorylineArchivesJob] Failed to persist failure marker for Lesson #{lesson.id}: #{write_err.class}: #{write_err.message}")
  end

  def mark_missing_source!(lesson, msg)
    attrs = {
      storyline_unzip_error: "Backfill missing source: #{msg}".truncate(10_000),
      storyline_unzip_failed_at: Time.current,
      updated_at: Time.current
    }

    if lesson.respond_to?(:storyline_unzip_status) && Lesson.respond_to?(:storyline_unzip_statuses)
      attrs[:storyline_unzip_status] = Lesson.storyline_unzip_statuses[:failed]
    end

    lesson.update_columns(attrs)
  rescue => write_err
    Rails.logger.error("[BackfillStorylineArchivesJob] Failed to mark missing storyline source for Lesson #{lesson.id}: #{write_err.class}: #{write_err.message}")
  end
end
