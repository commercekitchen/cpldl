class S3Uploader
  def initialize
    region = Rails.application.config.s3_region
    @s3_client = Aws::S3::Client.new(region: region)
    @bucket_name = Rails.application.config.s3_bucket_name
  end

  def copy_to_s3!(record, style: nil, attachment_name:)
    filename = record.send("#{attachment_name}_file_name")
    return unless filename.present?

    s3_path = "#{record.class.name.downcase.pluralize}/#{attachment_name.pluralize}/#{record.id}"
    s3_path += "/#{style}" if style.present?
    s3_path += "/#{filename}"

    file = File.open(record.send(attachment_name).path(style))

    puts "Uploading #{filename}..."
    
    @s3_client.put_object(bucket: @bucket_name, key: s3_path, body: file)
  rescue Aws::S3::Errors::NoSuchBucket => e
    puts "Creating the non-existing bucket: #{@bucket_name}"
    s3_client.create_bucket(bucket: @bucket_name)
    retry
  end
end
