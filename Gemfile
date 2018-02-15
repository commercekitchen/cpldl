# Use single quotes within config files.
# rubocop:disable Style/StringLiterals

source 'https://rubygems.org'

# Base set of gems
gem 'rails', '4.2.10'
gem 'pg'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'

gem 'sprockets-rails', '2.3.3'

# Full text search via PostgreSQL
gem 'pg_search'

# Leverage the SQL EXISTS to chec related tables
gem 'where_exists'

# Authentication and authorization
gem 'devise', '3.5.10'
gem 'devise_invitable'
gem 'rolify'
gem 'recaptcha', require: 'recaptcha/rails'

# Bourbon for sass mixins, and neat for the grid framework
gem 'bourbon'
gem 'neat'

# Redis for Sidekiq
gem 'redis'
gem 'redis-namespace'

# Background processing
gem 'sidekiq'
gem 'sinatra', require: nil # For the sidekiq web interface.
gem 'sidekiq-failures'

# Error reporting
gem 'rollbar'
gem 'newrelic_rpm'

gem 'paperclip', '~> 5.2.1' # File uploads
gem 'rubyzip' # ASL files
gem 'friendly_id'

gem 'ckeditor'

# PDF generation for completion certificate
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

# Local time helper library
gem 'local_time'

# integrate chosen library
# gem 'select2-rails'

group :development do
  gem 'rubocop', require: false
  gem 'brakeman', require: false
  gem 'quiet_assets'
  gem 'letter_opener'
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem "pry-remote"
  gem 'web-console', '~> 2.0'
  gem 'powder'
end

group :development, :test do
  gem "bundler-audit", require: false
  gem 'faker'
  gem 'pry'
  gem 'pry-nav'
  gem 'byebug'
  gem 'sunspot_solr'
  gem 'awesome_print', require: 'ap'
  gem 'rspec-rails', '~> 3.0'
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
  gem 'factory_girl_rails'
  gem 'capybara-webkit'
  gem 'mocha'
  gem 'database_cleaner'
  gem 'codeclimate-test-reporter'
  gem 'simplecov', require: false
  gem "shoulda-matchers"
  gem "timecop"
end

group :development, :staging do
  gem 'mail_interceptor'
end
