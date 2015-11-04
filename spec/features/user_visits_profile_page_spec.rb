require "feature_helper"

feature "Registered user visits account page" do

  before(:each) do
    @user = FactoryGirl.create(:user)
    login_as(@user)
  end

  scenario "can view their account options" do
    visit account_path
    expect(page).to have_content("Change Login Information")
    expect(page).to have_content("Update Profile")
    expect(page).to have_content("Your Completed Courses")
  end

  scenario "can change login information" do
    visit account_path
    fill_in "Email", with: "alex@commercekitchen.com"
    fill_in "user_password", with: "password"
    fill_in "user_password_confirmation", with: "password"
    click_button "Save"

    @user.reload
    expect(@user.unconfirmed_email).to eq("alex@commercekitchen.com")
    # TODO: how to check password changed?
  end

  scenario "can update their profile information" do
    visit profile_path
    fill_in "First name", with: "Alex"
    fill_in "Zip code", with: "12345"
    click_button "Save"

    @user.reload
    expect(@user.profile.first_name).to eq("Alex")
    expect(@user.profile.zip_code).to eq("12345")
  end

  scenario "can view completed courses" do
    # visit courses_completed_path
  end

end
