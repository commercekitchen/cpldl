class S3Store
  def initialize
    @client = Aws::S3::Client.new
  end

  def save(body:, key:)
    @client.put_object({
      bucket: S3_BUCKET_NAME,
      body: body,
      key: key
    })
  end

  def read(key:)
    @client.get_object({
      bucket: S3_BUCKET_NAME,
      key: key
    })
  end
end