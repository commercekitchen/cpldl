require "feature_helper"

feature "User signs up" do
  scenario "with valid email and password" do
    sign_up_with "valid@example.com", "password"
    expect(page).to have_content("A message with a confirmation link has been sent \
      to your email address. Please follow the link to activate your account.")
  end

  scenario "with invalid email" do
    sign_up_with "invalid_email", "password"
    expect(page).to have_content("Email is invalid")
  end

  scenario "with blank password" do
    sign_up_with "valid@example.com", ""
    expect(page).to have_content("Password can't be blank")
  end

  def sign_up_with(email, password)
    visit user_account_path
    find("#new_email").set(email)
    find("#new_password").set(password)
    fill_in "Password confirmation", with: password
    click_button "Sign up"
  end
end
