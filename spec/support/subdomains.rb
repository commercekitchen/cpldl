# frozen_string_literal: true

# Support for Rspec / Capybara subdomain integration testing
# Make sure this file is required by spec_helper.rb
# (e.g. save as spec/support/subdomains.rb)

def switch_to_subdomain(subdomain, tld = nil)
  # lvh.me always resolves to 127.0.0.1
  tld ||= 'lvh.me'
  host = subdomain ? "#{subdomain}.#{tld}" : tld

  url = "http://#{host}"
  Capybara.default_host = url
  Capybara.app_host = url
end

def switch_to_main_domain
  switch_to_subdomain nil
end

RSpec.configure do |_config|
  switch_to_main_domain
end

Capybara.configure do |config|
  config.always_include_port = true
end
