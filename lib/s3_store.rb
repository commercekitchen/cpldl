class S3Store
  def initialize
    @client = Aws::S3::Client.new
  end

  def save(file:, key:, acl:)
    @client.put_object({
      bucket: S3_BUCKET_NAME,
      body: file.get_input_stream.read,
      key: key,
      acl: acl
    })
  end
end