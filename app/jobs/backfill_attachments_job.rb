require "tempfile"
require "aws-sdk-s3"

class BackfillAttachmentsJob < ApplicationJob
  class MissingSourceObjectError < StandardError; end

  queue_as :maintenance

  retry_on StandardError, wait: :exponentially_longer, attempts: 3
  discard_on ActiveRecord::RecordNotFound

  def perform(args = {})
    args = args.with_indifferent_access

    start_id   = args[:start_id]
    batch_size = args[:batch_size] || 200

    scope = Attachment.order(:id)
    scope = scope.where("id >= ?", start_id) if start_id.present?

    batch = scope.limit(batch_size).to_a
    return if batch.empty?

    batch.each do |att|
      next if att.migrated_to_active_storage_at.present?
      next if att.document_file.attached?
      next unless att.respond_to?(:document) && att.document.exists?

      migrate_one!(att)
      att.update_columns(migrated_to_active_storage_at: Time.current, updated_at: Time.current)
    end

    self.class.perform_later(start_id: batch.last.id + 1, batch_size: batch_size)
  end

  private

  def migrate_one!(att)
    filename = att.document_file_name.to_s
    filename = "attachment#{att.id}" if filename.blank?

    content_type = att.document_content_type.presence || "application/octet-stream"

    Tempfile.create(["paperclip-", File.extname(filename)]) do |tmp|
      tmp.binmode

      begin
        if Rails.application.config.s3_enabled
          download_paperclip_from_s3_to!(att.document, tmp)
        else
          File.open(att.document.path, "rb") { |f| IO.copy_stream(f, tmp) }
        end
      rescue MissingSourceObjectError => e
        log_missing_source(att, e.message)
        return
      end

      tmp.rewind

      att.document_file.attach(
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
      s3.get_object(bucket: bucket, key: key) do |chunk|
        tmp.write(chunk)
      end
    rescue Aws::S3::Errors::NoSuchKey, Aws::S3::Errors::NotFound
      raise MissingSourceObjectError, "S3 object missing (bucket=#{bucket} key=#{key})"
    end
  end

  def log_missing_source(att, msg)
    Rails.logger.error("[Attachment Backfill] Missing source for Attachment #{att.id}: #{msg}")
  end
end
