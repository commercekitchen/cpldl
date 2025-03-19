require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DigitalLearn
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # This is needed to allow the test DB to load the functions needed for
    # pg_search from what we've done in the development.
    config.active_record.schema_format = :sql
    
    config.assets.unknown_asset_fallback = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.eager_load_paths << Rails.root.join('lib')

    require Rails.root.join("lib/custom_public_exceptions")
    config.exceptions_app = CustomPublicExceptions.new(Rails.public_path)

    # Separate I18n translation files
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    config.to_prepare do
      Devise::SessionsController.skip_before_action :require_valid_profile
    end

    # Load local env (aws credentials)
    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'local_env.yml')
      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
      end if File.exist?(env_file)
    end

    # S3 Proxy
    require Rails.root.join("lib/s3_proxy.rb")
    config.middleware.use S3Proxy, streaming: false

    # Attachment options
    config.s3_enabled = false # override to use S3 attachments
    config.s3_region = 'us-west-2'
    config.s3_bucket_name = "dl-uploads-#{Rails.env}"

    config.paperclip_defaults = {
      storage: :filesystem
    }

    # Ckeditor options
    config.ckeditor_paperclip_opts = {
      storage: :filesystem,
      url:  '/ckeditor_assets/:attachment/:id/:filename',
      path: ':rails_root/public/ckeditor_assets/attachments/:id/:filename'
    }

    config.ckeditor_paperclip_picture_opts = {
      storage: :filesystem,
      url: '/ckeditor_assets/pictures/:id/:style_:basename.:extension',
      path: ':rails_root/public/ckeditor_assets/pictures/:id/:style_:basename.:extension',
      styles: { content: '800>', thumb: '118x100#' }
    }

    # Default local lesson storage options
    config.lesson_store = :local
    config.storyline_paperclip_opts = {
      storage: :filesystem,
      url: '/system/lessons/story_lines/:id/:basename.:extension'
    }
  end
end
