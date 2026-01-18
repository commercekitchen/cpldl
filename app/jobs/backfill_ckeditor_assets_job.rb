require "open-uri"
require "tempfile"

class BackfillCkeditorAssetsJob < ApplicationJob
  queue_as :maintenance

  retry_on(
    Aws::S3::Errors::ServiceError,
    OpenURI::HTTPError,
    Timeout::Error,
    Errno::ECONNRESET,
    Errno::ETIMEDOUT,
    SocketError,
    wait: :exponentially_longer,
    attempts: 3
  )

  discard_on ActiveRecord::RecordNotFound

  def perform(start_id: nil, batch_size: 200)
    scope = Ckeditor::Asset.order(:id)
    scope = scope.where("id >= ?", start_id) if start_id.present?

    batch = scope.limit(batch_size).to_a
    return if batch.empty?

    batch.each do |asset|
      next if asset.migrated_to_active_storage_at.present?
      next if asset.data_file.attached?

      # During migration window only
      next unless asset.respond_to?(:data) && asset.data.present? && asset.data.exists?

      migrate_one!(asset)
      asset.update_columns(migrated_to_active_storage_at: Time.current, updated_at: Time.current)
    end

    # Enqueue next batch
    next_start_id = batch.last.id + 1
    self.class.perform_later(start_id: next_start_id, batch_size: batch_size)
  end

  private

  def migrate_one!(asset)
    filename     = asset.data_file_name.to_s
    content_type = asset.data_content_type.presence
    source       = Rails.application.config.s3_enabled ? asset.data.url : asset.data.path

    Tempfile.create(["ckeditor-", File.extname(filename)]) do |tmp|
      tmp.binmode
      URI.open(source) { |io| IO.copy_stream(io, tmp) }
      tmp.rewind
      asset.data_file.attach(io: tmp, filename: filename, content_type: content_type)
    end
  end
end
