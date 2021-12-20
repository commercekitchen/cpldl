class AttachmentReader
  def initialize(file)
    @file = file
  end

  def read_attachment_data(attachment_name)
    attachment = @file.send(attachment_name)

    if Rails.application.config.s3_enabled
      attachment_uri = URI.parse(attachment.url)
      open(attachment.url).read
    else
      open(attachment.path).read
    end
  end
end
