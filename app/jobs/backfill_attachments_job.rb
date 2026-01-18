require "open-uri"
require "tempfile"

class BackfillAttachmentsJob < ApplicationJob
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

  def perform(start_id = nil, batch_size = 200)
    scope = Attachment.order(:id)
    scope = scope.where("id >= ?", start_id) if start_id.present?

    batch = scope.limit(batch_size).to_a
    return if batch.empty?

    batch.each do |att|
      next if att.migrated_to_active_storage_at.present?
      next if att.document_file.attached?

      next unless asset.respond_to?(:document) && asset.document.present? && asset.document.exists?

      migrate_one!(att)
      att.update_columns(migrated_to_active_storage_at: Time.current, updated_at: Time.current)
    end

    next_start_id = batch.last.id + 1
    self.class.perform_later(start_id: next_start_id, batch_size: batch_size)
  end

  private

  def migrate_one!(att)
    filename     = att.document_file_name.to_s
    content_type = att.document_content_type.presence
    source       = Rails.application.config.s3_enabled ? att.document.url : att.document.path

    Tempfile.create(["paperclip-", File.extname(filename)]) do |tmp|
      tmp.binmode
      URI.open(source) { |io| IO.copy_stream(io, tmp) }
      tmp.rewind

      att.document_file.attach(io: tmp, filename: filename, content_type: content_type)
    end
  end
end
