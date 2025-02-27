# frozen_string_literal: true

require 'rails_helper'
require 'capybara/rails'
require 'capybara/rspec'
require 'selenium/webdriver'
require 'webmock/rspec'

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

Capybara.server = :webrick

# Use Selenium and Chromedriver for feature specs
Capybara.javascript_driver = :selenium_chrome_headless

# Configure webmock to disallow network connections
allowed_hosts = ['storage.googleapis.com', 'googlechromelabs.github.io', 'edgedl.me.gvt1.com']
WebMock.disable_net_connect!({ allow_localhost: true,
                               allow: allowed_hosts })
