# frozen_string_literal: true

class AttachmentReader
  def initialize(file)
    @file = file
  end

  def read_attachment_data(attachment_name)
    attachment = @file.send(attachment_name)

    if Rails.application.config.s3_enabled
      URI.open(attachment.url).read
    else
      URI.open(attachment.path).read
    end
  end
end
