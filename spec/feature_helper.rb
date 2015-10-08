require "rails_helper"
require "capybara/rails"
require "capybara/rspec"

def log_in_with(email, password)
  visit user_account_path
  find("#login_email").set(email)
  find("#login_password").set(password)
  click_button "Log in"
end

def sign_up_with(email, password)
  visit user_account_path
  find("#new_email").set(email)
  find("#new_password").set(password)
  fill_in "Password confirmation", with: password
  click_button "Sign up"
end

# examples
# def admin_login
#   click_link('Sign In')
#   expect(current_path).to eq(signin_path)
#   fill_in("Email", with: "admin@example.com")
#   fill_in("Password", with: "adminpassword")
#   click_button('Signin')
# end

# def default_login
#   click_link('Sign In')
#   expect(current_path).to eq(signin_path)
#   fill_in("Email", with: "user@example.com")
#   fill_in("Password", with: "userpassword")
#   click_button('Signin')
# end
