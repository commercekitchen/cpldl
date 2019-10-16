class S3Store
  def initialize
    @client = Aws::S3::Client.new
  end

  def save(file:, key:, acl:, zip_file: nil)
    @client.put_object({
      bucket: bucket_name,
      body: file.get_input_stream.read,
      key: key,
      acl: acl
    })
  end

  private

  def bucket_name
    Rails.configuration.s3_bucket_name
  end

  def s3_region
    Rails.configuration.s3_region
  end
end