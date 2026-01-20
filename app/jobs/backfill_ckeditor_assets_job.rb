require "tempfile"
require "aws-sdk-s3"

class BackfillCkeditorAssetsJob < ApplicationJob
  class MissingSourceObjectError < StandardError; end

  queue_as :maintenance

  retry_on StandardError, wait: :exponentially_longer, attempts: 3
  discard_on ActiveRecord::RecordNotFound

  def perform(args = {})
    args = args.with_indifferent_access

    start_id   = args[:start_id]
    batch_size = args[:batch_size] || 200

    scope = Ckeditor::Asset.order(:id)
    scope = scope.where("id >= ?", start_id) if start_id.present?

    batch = scope.limit(batch_size).to_a
    return if batch.empty?

    batch.each do |asset|
      next if asset.migrated_to_active_storage_at.present?
      next if asset.data_file.attached?
      next unless asset.respond_to?(:data) && asset.data.exists?

      migrate_one!(asset)
      asset.update_columns(migrated_to_active_storage_at: Time.current, updated_at: Time.current) if asset.respond_to?(:migrated_to_active_storage_at)
    end

    self.class.perform_later(start_id: batch.last.id + 1, batch_size: batch_size)
  end

  private

  def migrate_one!(asset)
    filename = asset.data_file_name.to_s
    filename = "ckeditor_asset#{asset.id}" if filename.blank?

    content_type = asset.data_content_type.presence || "application/octet-stream"

    Tempfile.create(["ckeditor-", File.extname(filename)]) do |tmp|
      tmp.binmode

      begin
        if Rails.application.config.s3_enabled
          download_paperclip_from_s3_to!(asset.data, tmp)
        else
          File.open(asset.data.path, "rb") { |f| IO.copy_stream(f, tmp) }
        end
      rescue MissingSourceObjectError => e
        log_missing_source(asset, e.message)
        return
      end

      tmp.rewind

      asset.data_file.attach(
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

  def log_missing_source(asset, msg)
    Rails.logger.error("[CKEditor Backfill] Missing source for Ckeditor::Asset #{asset.id}: #{msg}")
  end
end
