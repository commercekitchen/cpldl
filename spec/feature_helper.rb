require "rails_helper"
require "capybara/rails"
require "capybara/rspec"

def log_in_with(email, password)
  visit user_account_path
  find("#login_email").set(email)
  find("#login_password").set(password)
  click_button "Log in"
end

def log_out
  click_link "Sign Out"
end

def sign_up_with(email, password)
  visit user_account_path
  find("#new_email").set(email)
  find("#new_password").set(password)
  fill_in "Password confirmation", with: password
  click_button "Sign up"
end

def change_password(password)
  visit profile_path
  fill_in "user_password", with: password
  fill_in "user_password_confirmation", with: password
  click_button "Save"
end
