require "feature_helper"

feature "User signs up" do

  scenario "with valid email, password, first name, last name, zip code" do
    sign_up_with "valid@example.com", "password", "Alejandro", "12345"
    expect(page).to have_content("A message with a confirmation link has been sent \
      to your email address. Please follow the link to activate your account.")

    # TODO: I'm not sure this is the best place for this expectation, but I'm not
    # sure where else to put it.  I just want to be sure the profile is created too.
    user = User.last
    expect(user.profile.first_name).to eq("Alejandro")
    expect(user.profile.zip_code).to eq("12345")
  end

  scenario "with valid email, password, first name, but no zip code" do
    sign_up_with "valid@example.com", "password", "Alejandro", ""
    expect(page).to have_content("A message with a confirmation link has been sent \
      to your email address. Please follow the link to activate your account.")

    user = User.last
    expect(user.profile.first_name).to eq("Alejandro")
    expect(user.profile.zip_code).to eq("")
  end

  scenario "with out first name" do
    sign_up_with "valid@example.com", "password", "", ""
    expect(page).to have_content("Profile first name can't be blank")
  end

  scenario "with invalid email" do
    sign_up_with "invalid_email", "password", "John", "55555"
    expect(page).to have_content("Email is invalid")
  end

  scenario "with blank password" do
    sign_up_with "valid@example.com", "", "John", "55555"
    expect(page).to have_content("Password can't be blank")
  end

  scenario "with non-matching passwords" do
    visit login_path
    find("#signup_email").set("valid@example.com")
    find("#signup_password").set("password")
    fill_in "user_password_confirmation", with: "PASSWORD"
    click_button "Sign Up"
    expect(page).to have_content("Password confirmation doesn't match Password")
  end

end
