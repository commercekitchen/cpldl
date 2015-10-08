require "feature_helper"

feature "User logs in" do

  scenario "with valid email and password" do
    user = FactoryGirl.create(:user)
    log_in_with user.email, user.password
    expect(page).to have_content("Signed in successfully.")
  end

  scenario "with invalid or blank email" do
    log_in_with "", "password"
    expect(page).to have_content("Invalid email or password.")

    log_in_with "not@real.com", "password"
    expect(page).to have_content("Invalid email or password.")
  end

  scenario "with blank password" do
    log_in_with "valid@example.com", ""
    expect(page).to have_content("Invalid email or password.")

    log_in_with "valid@example.com", "no correct pwd"
    expect(page).to have_content("Invalid email or password.")
  end

  scenario "with unconfirmed email" do
    user = FactoryGirl.create(:unconfirmed_user)
    log_in_with user.email, user.password
    expect(page).to have_content("You have to confirm your email address before continuing.")
  end

end
