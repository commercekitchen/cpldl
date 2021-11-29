Rails.application.configure do
  config.active_record.dump_schema_after_migration = false

  config.force_ssl = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  # config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.serve_static_files = true

  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = true

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Eager load code on boot.
  config.eager_load = true

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Include stage component of tld
  config.action_dispatch.tld_length = 2

  # => to send email from local host
  #https://chipublib.digitallearn.org/
  config.action_mailer.default_url_options = { host: "stage.digitallearn.org" }
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.asset_host = "https://stage.digitallearn.org"

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = false

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  Paperclip.options[:command_path] = "/usr/local/bin/"

  ### S3 Lesson Configuration ###
  config.lesson_store = :s3
  config.cloudfront_url = 'https://dmx80r2ae8pd1.cloudfront.net'
  config.zip_bucket_name = 'dl-stageapp-lessons-zipped'

  config.storyline_paperclip_opts = {
    storage: :s3,
    path: 'storylines/:id/:basename.:extension',
    bucket: config.zip_bucket_name,
    s3_region: config.s3_region
  }
end
