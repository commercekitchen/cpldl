class S3Store
  BUCKET = S3_BUCKET_NAME.freeze

  def self.save(body:, key:)
    client.put_object({
      bucket: BUCKET,
      body: body,
      key: key
    })
  end

  def self.client
    Aws::S3::Client.new(
      access_key_id: Rails.application.secrets.s3_access_key,
      secret_access_key: Rails.application.secrets.s3_secret,
      region: "us-west-2"
    )
  end
end