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
      next if asset.respond_to?(:migrated_to_active_storage_at) && asset.migrated_to_active_storage_at.present?
      next if asset.data_file.attached?
      next unless asset.respond_to?(:data)

      migrate_one_by_trying_paths!(asset)
      asset.update_columns(migrated_to_active_storage_at: Time.current, updated_at: Time.current) if asset.respond_to?(:migrated_to_active_storage_at)
    end

    self.class.perform_later(start_id: batch.last.id + 1, batch_size: batch_size)
  end

  private

  def migrate_one_by_trying_paths!(asset)
    filename = asset.data_file_name.to_s
    filename = "ckeditor_asset#{asset.id}" if filename.blank?

    content_type = asset.data_content_type.presence || "application/octet-stream"

    Tempfile.create(["ckeditor-", File.extname(filename)]) do |tmp|
      tmp.binmode

      begin
        if Rails.application.config.s3_enabled
          download_from_s3_trying_candidates!(asset, tmp)
        else
          # Local disk fallback still can use Paperclip's path
          raise MissingSourceObjectError, "Local file missing: #{asset.data.path}" unless asset.data.exists?
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

  def download_from_s3_trying_candidates!(asset, tmp)
    s3 = Aws::S3::Client.new(region: Rails.application.config.s3_region)

    bucket = ckeditor_bucket_name(asset)
    keys   = candidate_s3_keys_for(asset)

    keys.each do |key|
      begin
        s3.get_object(bucket: bucket, key: key) { |chunk| tmp.write(chunk) }
        return
      rescue Aws::S3::Errors::NoSuchKey
        tmp.truncate(0)
        tmp.rewind
      end
    end

    raise MissingSourceObjectError, "S3 object missing (bucket=#{bucket} keys_tried=#{keys.take(15).join(', ')}#{'...' if keys.size > 15})"
  end

  # ---- Key generation ----

  def candidate_s3_keys_for(asset)
    filename = asset.data_file_name.to_s
    id       = asset.id

    case asset
    when Ckeditor::Picture
      [
        # Matches: ckeditor::pictures/data/18/content/cosla_logo.gif
        "ckeditor::pictures/data/#{id}/content/#{filename}",
        "ckeditor::pictures/data/#{id}/thumb/#{filename}",

        # Matches: ckeditor/pictures/data/25/puppy.jpeg
        "ckeditor/pictures/data/#{id}/#{filename}"
      ]
    when Ckeditor::AttachmentFile
      [
        # Matches: ckeditor::attachmentfiles/data/41/How_Do_I..._Zoom.pdf
        "ckeditor::attachmentfiles/data/#{id}/#{filename}",

        # If there is any chance you have mixed variants over time, these two are cheap insurance.
        "ckeditor::attachment_files/data/#{id}/#{filename}",
        "ckeditor/attachment_files/data/#{id}/#{filename}"
      ]
    end
  end

  def ckeditor_bucket_name(asset)
    # If you have the bucket configured globally (recommended), use that.
    # Otherwise, fall back to paperclip's bucket if available.
    Rails.application.config.try(:s3_bucket_name).presence ||
      asset.data.try(:s3_object).try(:bucket_name) ||
      raise("Cannot determine S3 bucket for CKEditor assets")
  end

  def log_missing_source(asset, msg)
    Rails.logger.error("[CKEditor Backfill] Missing source for #{asset.class.name} #{asset.id}: #{msg}")
  end
end
