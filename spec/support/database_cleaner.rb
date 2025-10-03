# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  # Default
  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  # ALL feature/system specs use non-transactional cleaning
  config.before(:each, type: :feature) do
    DatabaseCleaner.strategy = :truncation # (or :deletion if you prefer)
  end

  # If you also use :system specs:
  config.before(:each, type: :system) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) { DatabaseCleaner.start }
  config.append_after(:each) { DatabaseCleaner.clean }
end
