require "tempfile"
require "aws-sdk-s3"

class BackfillStorylineArchivesJob < ApplicationJob
  class MissingSourceObjectError < StandardError; end

  queue_as :maintenance

  retry_on StandardError, wait: :exponentially_longer, attempts: 3
  discard_on ActiveRecord::RecordNotFound
  discard_on MissingSourceObjectError

  def perform(args = {})
    args = args.with_indifferent_access

    start_id   = args[:start_id]
    batch_size = args[:batch_size] || 200

    scope = Lesson.order(:id)
    scope = scope.where("id >= ?", start_id) if start_id.present?

    batch = scope.limit(batch_size).to_a
    return if batch.empty?

    batch.each do |lesson|
      next if lesson.respond_to?(:migrated_to_active_storage_at) && lesson.migrated_to_active_storage_at.present?
      next if lesson.story_line_archive.attached?
      next unless lesson.respond_to?(:story_line) && lesson.story_line.exists?

      migrate_one!(lesson)

      if lesson.respond_to?(:migrated_to_active_storage_at)
        lesson.update_columns(migrated_to_active_storage_at: Time.current, updated_at: Time.current)
      end
    end

    self.class.perform_later(start_id: batch.last.id + 1, batch_size: batch_size)
  end

  private

  def migrate_one!(lesson)
    filename = lesson.story_line_file_name.to_s
    filename = "storyline_#{lesson.id}.zip" if filename.blank?

    content_type = lesson.story_line_content_type.presence || "application/zip"

    Tempfile.create(["storyline-", File.extname(filename)]) do |tmp|
      tmp.binmode

      begin
        if Rails.application.config.s3_enabled
          download_paperclip_from_s3_to!(lesson.story_line, tmp)
        else
          File.open(lesson.story_line.path, "rb") { |f| IO.copy_stream(f, tmp) }
        end
      rescue MissingSourceObjectError => e
        mark_missing_source!(lesson, e.message)
        return
      end

      tmp.rewind

      lesson.story_line_archive.attach(
        io: tmp,
        filename: filename,
        content_type: content_type
      )
    end
  end

  def download_paperclip_from_s3_to!(paperclip_attachment, tmp)
    s3_obj = paperclip_attachment.s3_object
    bucket = s3_obj.bucket_name
    key    = s3_obj.key

    s3 = Aws::S3::Client.new(region: Rails.application.config.s3_region)

    begin
      s3.get_object(bucket: bucket, key: key) { |chunk| tmp.write(chunk) }
    rescue Aws::S3::Errors::NoSuchKey, Aws::S3::Errors::NotFound
      raise MissingSourceObjectError, "S3 object missing (bucket=#{bucket} key=#{key})"
    end
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
    Rails.logger.error("Failed to mark missing storyline source for Lesson #{lesson.id}: #{write_err.class}: #{write_err.message}")
  end
end
