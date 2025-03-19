# frozen_string_literal: true

require 'rails_helper'
require 'capybara/rails'
require 'capybara/rspec'
require 'selenium/webdriver'

Capybara.register_driver :selenium_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new') # Use the new headless mode (Chrome 109+)
  options.add_argument('--disable-gpu')
  options.add_argument('--no-sandbox')
  options.add_argument('--window-size=1920,1400')
  options.add_argument('--disable-software-rasterizer') # Don't use SwiftShader to render images via CPU

  # options.add_argument('--disable-dev-shm-usage') # Use tmp instead of shm memory for storage
  options.add_argument('--remote-debugging-port=9222') # Improve stability by using a dedicated remote debugging port

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :selenium_headless

Capybara.default_host =
  "http://#{Rails.application.routes.default_url_options[:host]}:#{Rails.application.routes.default_url_options[:port]}"

# Don't run animations in browser
Capybara.disable_animation = true

RSpec.configure do |config|
  config.before(:each, type: :system) { driven_by Capybara.default_driver }

  config.before(:each, type: :system, js: true) do
    driven_by Capybara.javascript_driver
    Capybara.current_session.driver.browser.manage.delete_all_cookies

    # Use capybara host & port in url helpers
    Rails.application.routes.default_url_options[:host] = Capybara.current_session.server.host
    Rails.application.routes.default_url_options[:port] = Capybara.current_session.server.port
  end
end

# TODO: Consolidate these 4 methods into one method with keyword args, maybe?
def log_in_with(email, password, admin = nil)
  visit new_user_session_path(admin: admin)
  find('#login_email').set(email)
  find('#login_password').set(password)
  click_button 'Access Courses'
end

def library_card_log_in_with(card_number, password)
  visit new_user_session_path
  find('#login_library_card_number').set(card_number)
  find('#login_password').set(password)
  click_button 'Access Courses'
end

def spanish_log_in_with(email, password)
  visit new_user_session_path
  find('#login_email').set(email)
  find('#login_password').set(password)
  click_button 'Accesar Cursos'
end

def spanish_library_card_log_in_with(card_number, password)
  visit new_user_session_path
  find('#login_library_card_number').set(card_number)
  find('#login_password').set(password)
  click_button 'Accesar Cursos'
end

def log_out
  click_link 'Sign Out'
end

def sign_up_with(email, password, first_name, zip_code)
  visit login_path
  find('#signup_email').set(email)
  find('#signup_password').set(password)
  find('#user_profile_attributes_first_name').set(first_name)
  find('#user_profile_attributes_zip_code').set(zip_code)
  fill_in 'user_password_confirmation', with: password
  click_button 'Sign Up'
end

def library_card_sign_up_with(card_number, card_pin, first_name, zip_code)
  visit login_path
  find('#library_card_number').set(card_number)
  find('#library_card_pin').set(card_pin)
  find('#user_profile_attributes_first_name').set(first_name)
  find('#user_profile_attributes_zip_code').set(zip_code)
  click_button 'Sign Up'
end

def change_password(password)
  visit profile_path
  fill_in 'user_password', with: password
  fill_in 'user_password_confirmation', with: password
  click_button 'Save'
end

def fill_in_ckeditor(locator, opts)
  content = opts.fetch(:with).to_json # convert to a safe javascript string
  page.execute_script <<-SCRIPT
    CKEDITOR.instances['#{locator}'].setData(#{content});
    $('textarea##{locator}').text(#{content});
  SCRIPT
end
