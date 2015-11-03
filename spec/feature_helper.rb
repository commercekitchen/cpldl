require "rails_helper"
require "capybara/rails"
require "capybara/rspec"

def log_in_with(email, password)
  visit new_user_session_path
  find("#login_email").set(email)
  find("#login_password").set(password)
  click_button "Access Courses"
end

def log_out
  click_link "Sign Out"
end

def sign_up_with(email, password, first_name, last_name, zip_code)
  visit login_path
  find("#signup_email").set(email)
  find("#signup_password").set(password)
  find("#user_profile_attributes_first_name").set(first_name)
  find("#user_profile_attributes_last_name").set(last_name)
  find("#user_profile_attributes_zip_code").set(zip_code)
  fill_in "user_password_confirmation", with: password
  click_button "Sign Up"
end

def change_password(password)
  visit profile_path
  fill_in "user_password", with: password
  fill_in "user_password_confirmation", with: password
  click_button "Save"
end

Capybara.javascript_driver = :webkit
Capybara::Webkit.configure do |config|
  # TODO: revisit after development
  config.allow_url("placeholdit.imgix.net")
  config.allow_url("placehold.it")
  # config.debug = true
end