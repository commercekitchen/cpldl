# frozen_string_literal: true

# Code coverage - configuration is in .simplecov file
require 'simplecov'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'pry'
require 'spec_helper'
require 'rspec/rails'
require 'pundit/rspec'
require 'validate_url/rspec_matcher'

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false # Set to false when using database_cleaner

  config.include Devise::Test::ControllerHelpers, type: :helper

  %i[controller view].each do |type|
    # Devise controller helpers
    config.include Devise::Test::ControllerHelpers, type: type

    # Controller tests
    config.include ::Rails::Controller::Testing::TestProcess, type: type
    config.include ::Rails::Controller::Testing::TemplateAssertions, type: type
    config.include ::Rails::Controller::Testing::Integration, type: type
  end

  # Lines 43 to 53 are to allow views to mock access to helper methods in
  # application helper
  config.before(:each, type: :view) do
    config.mock_with :rspec do |mocks|
      mocks.verify_partial_doubles = false
    end
  end

  config.before(:each) do
    @english = FactoryBot.create(:language)
    @spanish = FactoryBot.create(:spanish_lang)
    I18n.locale = :en
  end

  # Reset test host
  config.before(:each) do
    switch_to_subdomain('')
  end

  config.after(:each, type: :view) do
    config.mock_with :rspec do |mocks|
      mocks.verify_partial_doubles = true
    end
  end

  # Remove test storylines
  config.after(:suite) do
    FileUtils.rm_rf Rails.root.join('public', 'system', 'lessons', 'story_lines')
  end

  include ActionDispatch::TestProcess

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!
end
