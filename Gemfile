# frozen_string_literal: true

source 'https://rubygems.org'

# Base set of gems
gem 'jquery-rails'
gem 'pg'
gem 'puma'
gem 'rails', '~> 7.1.4'
gem 'sassc-rails'
gem 'terser', '~> 1.2'

gem 'sprockets-rails', '>= 3.0'

# Full text search via PostgreSQL
gem 'pg_search'

# Leverage the SQL EXISTS to chec related tables
gem 'where_exists', '>= 1.0.0'

# Authentication and authorization
gem 'devise', '>= 4.6.0'
gem 'devise_invitable', '>= 2.0.0'
gem 'pundit'
gem 'recaptcha'
gem 'rolify'

# Redis for Sidekiq
gem 'redis'
gem 'redis-namespace'

# Background processing
gem 'sidekiq', '< 8'

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
gem 'data_migrate', '~> 11.2'

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

# Cocoon for dynamic nested forms
gem 'cocoon'

# Freeze nokogiri version
gem 'nokogiri', '~> 1.15.5'

# Tools to make the site an OAuth Provider
gem 'doorkeeper', '~> 5.8'

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
  # gem 'sunspot_solr'
  # gem 'spring'
  # gem 'httplog' # Note: uncomment and bundle to see api calls, if needed.
end

group :test do
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'mocha'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver', '~> 4.0'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'timecop'
end
