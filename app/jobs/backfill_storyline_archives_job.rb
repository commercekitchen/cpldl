require "open-uri"
require "tempfile"

class BackfillStorylineArchivesJob < ApplicationJob
  queue_as :maintenance

  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  # Not available in Rails 5
  # retry_on(
  #   Aws::S3::Errors::ServiceError,
  #   OpenURI::HTTPError,
  #   Timeout::Error,
  #   Errno::ECONNRESET,
  #   Errno::ETIMEDOUT,
  #   SocketError,
  #   wait: :exponentially_longer,
  #   attempts: 3
  # )

  discard_on ActiveRecord::RecordNotFound

  def perform(start_id: nil, batch_size: 100)
    scope = Lesson.order(:id)
    scope = scope.where("id >= ?", start_id) if start_id.present?

    batch = scope.limit(batch_size).to_a
    return if batch.empty?

    batch.each do |lesson|
      next if lesson.story_line_archive.attached?
      next unless lesson.respond_to?(:story_line) && lesson.story_line.present? && lesson.story_line.exists?

      migrate_one!(lesson)
      # If you added a timestamp column, set it here; otherwise omit.
      lesson.update_columns(migrated_to_active_storage_at: Time.current, updated_at: Time.current) if lesson.respond_to?(:migrated_to_active_storage_at)
    end

    self.class.perform_later(start_id: batch.last.id + 1, batch_size: batch_size)
  end

  private

  def migrate_one!(lesson)
    filename     = lesson.story_line_file_name.to_s
    content_type = lesson.story_line_content_type.presence || "application/zip"
    source       = Rails.application.config.s3_enabled ? lesson.story_line.url : lesson.story_line.path

    Tempfile.create(["storyline-", File.extname(filename)]) do |tmp|
      tmp.binmode
      URI.open(source) { |io| IO.copy_stream(io, tmp) }
      tmp.rewind

      lesson.story_line_archive.attach(
        io: tmp,
        filename: filename,
        content_type: content_type
      )
    end
  end
end
