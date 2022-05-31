# frozen_string_literal: true

source 'https://rubygems.org'

# Base set of gems
gem 'jquery-rails', '>= 4.3.0'
gem 'pg'
gem 'puma'
gem 'rails', '~> 5.2.8'
gem 'sass-rails', '>= 6.0.0'
gem 'uglifier'

gem 'sprockets-rails', '>= 3.0'

# Full text search via PostgreSQL
gem 'pg_search'

# Leverage the SQL EXISTS to chec related tables
gem 'where_exists', '>= 1.0.0'

# Authentication and authorization
gem 'devise', '>= 4.6.0'
gem 'devise_invitable', '>= 2.0.0'
gem 'pundit'
gem 'recaptcha', require: 'recaptcha/rails'
gem 'rolify'

# Redis for Sidekiq
gem 'redis'
gem 'redis-namespace'

# Background processing
gem 'sidekiq', '>= 5.0', '< 6.0'
gem 'sidekiq-failures'
gem 'sinatra', '>= 2.0', require: nil # For the sidekiq web interface.

# Error reporting
gem 'rollbar'

gem 'friendly_id', '>= 5.1'
gem 'paperclip' # File uploads
gem 'rubyzip', '~> 1.0' # ASL files

# PDF generation for completion certificate
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

# Local time helper library
gem 'local_time', '>= 2.0'

# i18n customization
gem 'i18n-active_record', require: 'i18n/active_record'

# Prevent botspam and allow white/blacklisting IPs, etc
gem 'rack-attack'

# Encrypt attributes to avoid storing plaintext in DB
gem 'attr_encrypted'

# Cast blanks to nil
gem 'nilify_blanks'

# Use data migrations in addition to schema migrations
gem 'data_migrate', '~> 5.3.2'

# integrate chosen library
# gem 'select2-rails'

gem 'storext'
gem 'validate_url'

# Rails 5 gems
gem 'bootsnap', require: false
gem 'listen'

# CKEditor
gem 'ckeditor', '~> 4.3.0'

# AWS sdk for s3
gem 'aws-sdk-s3', '~> 1'

# Rack::Proxy for S3 Proxy middleware
gem 'rack-proxy'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'brakeman', require: false
  gem 'letter_opener'
  gem 'powder'
  gem 'pry-remote'
  gem 'rails-erd'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'web-console', '~> 3.7.0'
end

group :development, :test do
  gem 'awesome_print'
  gem 'bullet'
  gem 'bundler-audit', require: false
  gem 'byebug'
  gem 'faker'
  gem 'pry'
  gem 'pry-nav'
  gem 'rspec-rails', '>= 3.8.0'
  gem 'sunspot_solr'
  # gem 'spring'
  # gem 'httplog' # Note: uncomment and bundle to see api calls, if needed.
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_bot_rails', '~> 4.10.0'
  gem 'launchy'
  gem 'mocha'
  gem 'rails-controller-testing'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'timecop'
  gem 'webdrivers'
  gem 'webmock'
end
