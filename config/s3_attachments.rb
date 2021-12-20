module CPLDigitalLearn
  class Application < Rails::Application
    config.s3_enabled = true

    # S3 Paperclip options
    config.paperclip_defaults = {
      storage: :s3,
      s3_protocol: :https,
      path: ":class/:attachment/:id/:basename.:extension",
      bucket: config.s3_bucket_name,
      s3_region: config.s3_region,
      s3_host_name: "s3-#{config.s3_region}.amazonaws.com"
    }

    # Ckeditor options
    config.ckeditor_paperclip_opts = config.paperclip_defaults

    config.ckeditor_paperclip_picture_opts = config.paperclip_defaults.merge({
      styles: { content: '800>', thumb: '118x100#' }
    })
  end
end