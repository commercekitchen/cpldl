require "tempfile"
require "aws-sdk-s3"
require "securerandom"

class BackfillAttachmentsJob < ApplicationJob
  class MissingSourceObjectError < StandardError; end

  queue_as :maintenance

  retry_on StandardError, wait: :exponentially_longer, attempts: 3
  discard_on ActiveRecord::RecordNotFound

  def perform(args = {})
    args = args.with_indifferent_access

    start_id   = args[:start_id]
    batch_size = (args[:batch_size] || 200).to_i
    verbose    = !!args[:verbose]
    run_id     = args[:run_id].presence || SecureRandom.hex(6)

    scope = Attachment.order(:id)
    scope = scope.where("id >= ?", start_id) if start_id.present?

    batch = scope.limit(batch_size).to_a
    return if batch.empty?

    stats = Hash.new(0)
    stats[:batch_size] = batch.size

    Rails.logger.info("[BackfillAttachmentsJob][run=#{run_id}] Starting batch start_id=#{start_id.inspect} size=#{batch.size}")

    batch.each do |att|
      stats[:examined] += 1

      begin
        skip_reason = skip_reason_for(att)
        if skip_reason
          stats[:"skipped_#{skip_reason}"] += 1
          Rails.logger.info("[BackfillAttachmentsJob][run=#{run_id}] Attachment #{att.id} skipped=#{skip_reason}") if verbose
          next
        end

        stats[:attempted] += 1

        bytes = migrate_one!(att, run_id: run_id)

        if bytes == :missing_source
          stats[:missing_source] += 1
          next
        end

        # Verify attach actually persisted
        att.reload
        unless att.document_file.attached?
          raise "Attach did not persist (document_file not attached after reload)"
        end

        blob = att.document_file.blob
        if blob.nil? || blob.byte_size.to_i <= 0
          raise "Attach persisted but blob missing/empty (blob_id=#{blob&.id.inspect} byte_size=#{blob&.byte_size.inspect})"
        end

        stats[:succeeded] += 1
        Rails.logger.info("[BackfillAttachmentsJob][run=#{run_id}] Attachment #{att.id} attached blob_id=#{blob.id} bytes=#{blob.byte_size}") if verbose

        # Mark success only after verification
        if att.respond_to?(:migrated_to_active_storage_at)
          att.update_columns(migrated_to_active_storage_at: Time.current, updated_at: Time.current)
        end

        clear_backfill_error!(att) # no-op if columns don’t exist
      rescue MissingSourceObjectError => e
        stats[:missing_source] += 1
        mark_missing_source!(att, e.message, run_id: run_id)
      rescue => e
        stats[:failed] += 1
        mark_failed!(att, e, run_id: run_id)
        Rails.logger.error("[BackfillAttachmentsJob][run=#{run_id}] Attachment #{att.id} FAILED #{e.class}: #{e.message}\n#{e.backtrace&.first(15)&.join("\n")}")
        # Continue to next record; don’t blow up the batch.
      end
    end

    Rails.logger.info("[BackfillAttachmentsJob][run=#{run_id}] Batch done start_id=#{start_id.inspect} last_id=#{batch.last.id} stats=#{stats.inspect}")

    self.class.perform_later(
      start_id: batch.last.id + 1,
      batch_size: batch_size,
      run_id: run_id,
      verbose: verbose
    )
  end

  private

  def skip_reason_for(att)
    if att.respond_to?(:migrated_to_active_storage_at) && att.migrated_to_active_storage_at.present?
      return :already_migrated
    end

    if att.document_file.attached?
      return :already_attached
    end

    unless att.respond_to?(:document)
      return :no_paperclip_method
    end

    # Paperclip "exists?" is a frequent silent killer. This makes it explicit.
    unless att.document.exists?
      return :paperclip_missing
    end

    nil
  end

  def migrate_one!(att, run_id:)
    filename = att.document_file_name.to_s
    filename = "attachment#{att.id}" if filename.blank?
    content_type = att.document_content_type.presence || "application/octet-stream"

    Tempfile.create(["paperclip-", File.extname(filename)]) do |tmp|
      tmp.binmode

      begin
        bytes =
          if Rails.application.config.s3_enabled
            download_paperclip_from_s3_to!(att.document, tmp)
          else
            download_paperclip_from_disk_to!(att.document, tmp)
          end
      rescue MissingSourceObjectError => e
        mark_missing_source!(att, e.message, run_id: run_id)
        Rails.logger.warn("[BackfillAttachmentsJob][run=#{run_id}] Attachment #{att.id} missing_source #{e.message}")
        return :missing_source
      end

      tmp.rewind

      att.document_file.attach(
        io: tmp,
        filename: filename,
        content_type: content_type
      )

      bytes
    end
  end

  def download_paperclip_from_disk_to!(paperclip_attachment, tmp)
    path = paperclip_attachment.path
    raise MissingSourceObjectError, "Local file missing (path=#{path})" unless path.present? && File.exist?(path)

    bytes = 0
    File.open(path, "rb") do |f|
      bytes = IO.copy_stream(f, tmp)
    end
    bytes.to_i
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

  # ---- Persistence helpers (safe even if columns don’t exist) ----

  def mark_missing_source!(att, msg, run_id:)
    # Prefer persisting; fallback to logging
    if att.respond_to?(:backfill_error=) || att.respond_to?(:backfill_failed_at=)
      attrs = {}
      attrs[:backfill_error] = "Missing source [run=#{run_id}]: #{msg}".to_s.truncate(10_000) if att.respond_to?(:backfill_error=)
      attrs[:backfill_failed_at] = Time.current if att.respond_to?(:backfill_failed_at=)
      attrs[:updated_at] = Time.current if att.respond_to?(:updated_at)
      att.update_columns(attrs) if attrs.any?
    else
      Rails.logger.error("[BackfillAttachmentsJob][run=#{run_id}] Missing source for Attachment #{att.id}: #{msg}")
    end
  rescue => write_err
    Rails.logger.error("[BackfillAttachmentsJob] Failed to persist missing_source marker for Attachment #{att.id}: #{write_err.class}: #{write_err.message}")
  end

  def mark_failed!(att, err, run_id:)
    msg =
      +"Backfill failed [run=#{run_id}] #{err.class}: #{err.message}\n" \
      "attachment_id=#{att.id}\n" \
      "#{(err.backtrace || []).first(30).join("\n")}"

    if att.respond_to?(:backfill_error=) || att.respond_to?(:backfill_failed_at=)
      attrs = {}
      attrs[:backfill_error] = msg.truncate(10_000) if att.respond_to?(:backfill_error=)
      attrs[:backfill_failed_at] = Time.current if att.respond_to?(:backfill_failed_at=)
      attrs[:updated_at] = Time.current if att.respond_to?(:updated_at)
      att.update_columns(attrs) if attrs.any?
    else
      Rails.logger.error("[BackfillAttachmentsJob][run=#{run_id}] Attachment #{att.id} FAILED: #{err.class}: #{err.message}")
    end
  rescue => write_err
    Rails.logger.error("[BackfillAttachmentsJob] Failed to persist failure marker for Attachment #{att.id}: #{write_err.class}: #{write_err.message}")
  end

  def clear_backfill_error!(att)
    return unless att.respond_to?(:backfill_error=) || att.respond_to?(:backfill_failed_at=)

    attrs = {}
    attrs[:backfill_error] = nil if att.respond_to?(:backfill_error=)
    attrs[:backfill_failed_at] = nil if att.respond_to?(:backfill_failed_at=)
    attrs[:updated_at] = Time.current if att.respond_to?(:updated_at)
    att.update_columns(attrs) if attrs.any?
  rescue
    # non-fatal
  end
end
