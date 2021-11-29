class AttachmentReader
  def initialize(file)
    @file = file
  end

  def read_attachment_data(attachment_name)
    attachment_path = @file.send(attachment_name).path

    if Rails.application.config.s3_enabled
      s3 = Aws::S3::Client.new
      response = s3.get_object({
        bucket: Rails.application.config.s3_bucket_name,
        key: attachment_path
      })
      response.body.read
    else
      open(attachment_path).read
    end
  end
end
