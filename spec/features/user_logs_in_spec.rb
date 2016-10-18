require "feature_helper"

feature "User logs in" do

  before(:each) do
    @org = create(:organization)
    @spanish = create(:spanish_lang)
    @english = create(:language)
    switch_to_subdomain("chipublib")
  end

  scenario "with valid email and password" do
    user = create(:user, organization: @org)
    user.add_role(:user, @org)
    log_in_with(user.email, user.password)
    expect(current_path).to eq(root_path)
    expect(page).to_not have_content("Signed in successfully.")
    expect(page).to have_content("Use a computer to do almost anything!")
    expect(page).to have_content(
      "Choose a course below to start learning, or visit My Courses to view your customized learning plan."
    )
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
    user = create(:unconfirmed_user)
    log_in_with user.email, user.password
    expect(page).to have_content("You have to confirm your email address before continuing.")
  end

end
