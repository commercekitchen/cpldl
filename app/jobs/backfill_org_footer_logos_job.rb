require "tempfile"
require "aws-sdk-s3"

class BackfillOrgFooterLogosJob < ApplicationJob
  class MissingSourceObjectError < StandardError; end

  queue_as :maintenance

  retry_on StandardError, wait: :exponentially_longer, attempts: 3
  discard_on ActiveRecord::RecordNotFound

  def perform(args = {})
    args = args.with_indifferent_access

    start_id   = args[:start_id]
    batch_size = args[:batch_size] || 200

    scope = Organization.order(:id)
    scope = scope.where("id >= ?", start_id) if start_id.present?

    batch = scope.limit(batch_size).to_a
    return if batch.empty?

    batch.each do |org|
      next if org.footer_logo_file.attached?
      next unless org.respond_to?(:footer_logo) && org.footer_logo.exists?

      migrate_one!(org)
    end

    self.class.perform_later(start_id: batch.last.id + 1, batch_size: batch_size)
  end

  private

  def migrate_one!(org)
    filename = org.footer_logo_file_name.to_s
    filename = "footer_logo_#{org.id}" if filename.blank?

    content_type = org.footer_logo_content_type.presence || "application/octet-stream"

    Tempfile.create(["footer-logo-", File.extname(filename)]) do |tmp|
      tmp.binmode

      begin
        if Rails.application.config.s3_enabled
          download_paperclip_from_s3_to!(org.footer_logo, tmp)
        else
          File.open(org.footer_logo.path, "rb") { |f| IO.copy_stream(f, tmp) }
        end
      rescue MissingSourceObjectError => e
        log_missing_source(org, e.message)
        return
      end

      tmp.rewind

      org.footer_logo_file.attach(
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

  def log_missing_source(org, msg)
    Rails.logger.error("[Footer Logo Backfill] Missing source for Organization #{org.id}: #{msg}")
  end
end
