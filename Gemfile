# Use single quotes within config files.
# rubocop:disable Style/StringLiterals

source 'https://rubygems.org'

# Base set of gems
gem 'rails', '>= 5.2.0', '< 6.0'
gem 'pg'
gem 'sass-rails', '>= 6.0.0'
gem 'uglifier'
gem 'jquery-rails', '>= 4.3.0'

gem 'sprockets-rails', '>= 3.0'

# Full text search via PostgreSQL
gem 'pg_search'

# Leverage the SQL EXISTS to chec related tables
gem 'where_exists', '>= 1.0.0'

# Authentication and authorization
gem 'devise', '>= 4.6.0'
gem 'devise_invitable', '>= 2.0.0'
gem 'rolify'
gem 'recaptcha', require: 'recaptcha/rails'

# Bourbon for sass mixins, and neat for the grid framework
gem 'bourbon', '< 5.0'
gem 'neat', '< 2.0'

# Redis for Sidekiq
gem 'redis'
gem 'redis-namespace'

# Background processing
gem 'sidekiq', '>= 5.0'
gem 'sinatra', '>= 2.0', require: nil # For the sidekiq web interface.
gem 'sidekiq-failures'

# Error reporting
gem 'rollbar'

gem 'paperclip' # File uploads
gem 'rubyzip', '~> 1.0' # ASL files
gem 'friendly_id', '>= 5.1'

gem 'ckeditor'

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

group :development do
  gem 'rubocop', require: false
  gem 'brakeman', require: false
  gem 'letter_opener'
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem "pry-remote"
  gem 'web-console', '~> 3.7.0'
  gem 'powder'
end

group :development, :test do
  gem 'bundler-audit', require: false
  gem 'faker'
  gem 'pry'
  gem 'pry-nav'
  gem 'byebug'
  gem 'sunspot_solr'
  gem 'awesome_print', require: 'ap'
  gem 'rspec-rails', '>= 3.8.0'
  gem 'bullet'
  # gem 'spring'
  # gem 'httplog' # Note: uncomment and bundle to see api calls, if needed.
end

# Capistrano Deployment
group :development, :deployment do
  gem 'capistrano', '3.4.0', require: false # Deploy is locked to this version.
  gem 'capistrano-rails', '~> 1.1.3', require: false
  gem 'capistrano-rvm', require: false
  gem 'capistrano-faster-assets', '~> 1.0', require: false
  gem 'capistrano-db-tasks', '~> 0.4', require: false
  gem 'capistrano-sidekiq', require: false
  gem 'colorize'
end

group :test do
  gem 'launchy'
  gem 'factory_bot_rails', '~> 4.10.0'
  gem 'capybara'
  gem 'chromedriver-helper'
  gem 'selenium-webdriver', '~> 3.0'
  gem 'mocha'
  gem 'database_cleaner'
  gem 'codeclimate-test-reporter'
  gem 'simplecov', require: false
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'webmock'
end

group :development, :staging do
  gem 'mail_interceptor'
end
