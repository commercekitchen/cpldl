# Use single quotes within config files.
# rubocop:disable Style/StringLiterals

source 'https://rubygems.org'

# Base set of gems
gem 'rails', '4.2.4'
gem 'pg'
gem 'sqlite3'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'

# Authentication and authorization
gem 'devise'
gem 'rolify'

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
gem 'honeybadger', '~> 2.0'
gem 'newrelic_rpm'

gem 'paperclip', '~> 4.3' # File uploads
gem 'friendly_id'

group :development do
  gem 'rubocop', require: false
  gem 'brakeman', require: false
  gem 'quiet_assets'
  gem 'letter_opener'
end

group :development, :test do
  gem 'faker'
  gem 'pry'
  gem 'pry-nav'
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  # gem 'spring'
  gem 'sunspot_solr'
  gem 'awesome_print', require: 'ap'
  gem 'rspec-rails', '~> 3.0'
  gem 'bullet'
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
end

group :test do
  gem 'launchy'
  gem 'factory_girl_rails'
  gem 'capybara-webkit'
  gem 'mocha'
  gem 'database_cleaner'
  gem "codeclimate-test-reporter"
  # gem 'webmock'
end
