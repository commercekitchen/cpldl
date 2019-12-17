# frozen_string_literal: true

class S3Store
  def initialize
    @client = Aws::S3::Client.new
  end

  def save(file:, key:, **opts)
    acl = opts[:acl]
    Rails.logger.debug(key)
    @client.put_object({ bucket: bucket_name,
                         body: file.get_input_stream.read,
                         key: key,
                         acl: acl })
  end

  private

  def bucket_name
    Rails.configuration.zip_bucket_name
  end
end
