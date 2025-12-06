require 'zip'

class UnzipStorylineJob < ApplicationJob
  queue_as :default

  def perform(lesson_id)
    lesson = Lesson.find(lesson_id)
    blob   = lesson.story_line_archive&.blob
    return unless blob

    root_path = lesson.storyline_root_path
    raise "Missing storyline_root_path for Lesson #{lesson.id}" if root_path.blank?

    s3 = Aws::S3::Client.new
    bucket = Rails.configuration.lesson_unzipped_bucket

    # Download the zip from ActiveStorage
    zip_bytes = blob.download

    Zip::File.open_buffer(zip_bytes) do |zip_file|
      zip_file.each do |entry|
        next if entry.name_is_directory?

        key = "#{root_path}/#{entry.name}" # storylines/:id/:slug/<entry>

        # You can tune MIME; Marcel is already used by ActiveStorage
        content_type = Marcel::MimeType.for(
          extension: File.extname(entry.name),
          name: entry.name,
          declared_type: 'application/octet-stream'
        )

        s3.put_object(
          bucket: bucket,
          key: key,
          body: entry.get_input_stream.read,
          acl: 'private',
          content_type: content_type,
          content_disposition: 'inline'
        )
      end
    end
  end
end
