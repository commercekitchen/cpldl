require "rails_helper"
require "capybara/rails"
require "capybara/rspec"
require "selenium/webdriver"
require "webmock/rspec"

def log_in_with(email, password, admin = nil)
  visit new_user_session_path(admin: admin)
  find("#login_email").set(email)
  find("#login_password").set(password)
  click_button "Access Courses"
end

def spanish_log_in_with(email, password)
  visit new_user_session_path
  find("#login_email").set(email)
  find("#login_password").set(password)
  click_button "Accesar Cursos"
end

def log_out
  click_link "Sign Out"
end

def sign_up_with(email, password, first_name, zip_code)
  visit login_path
  find("#signup_email").set(email)
  find("#signup_password").set(password)
  find("#user_profile_attributes_first_name").set(first_name)
  find("#user_profile_attributes_zip_code").set(zip_code)
  fill_in "user_password_confirmation", with: password
  click_button "Sign Up"
end

def library_card_sign_up_with(card_number, card_pin, first_name, zip_code)
  visit login_path
  find("#library_card_number").set(card_number)
  find("#library_card_pin").set(card_pin)
  find("#user_profile_attributes_first_name").set(first_name)
  find("#user_profile_attributes_zip_code").set(zip_code)
  click_button "Sign Up"
end

def change_password(password)
  visit profile_path
  fill_in "user_password", with: password
  fill_in "user_password_confirmation", with: password
  click_button "Save"
end

Capybara.server = :webrick

# Use Selenium and Chromedriver for feature specs because
# webkit is broken for newer versions of xcode/macOS
Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w[headless disable-gpu] }
  )

  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    desired_capabilities: capabilities
end

Capybara.javascript_driver = :headless_chrome

# Configure webmock to disallow network connections
WebMock.disable_net_connect!(allow_localhost: true)
