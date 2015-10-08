require "feature_helper"

feature "Registered user visits profile page" do

  before(:all) do
    @user = FactoryGirl.create(:user)
    login_as(@user)
  end

  scenario "updates their profile information" do
    visit profile_path
    fill_in "Email", with: "alex@commercekitchen.com"
    fill_in "user_password", with: "password"
    fill_in "user_password_confirmation", with: "password"
    fill_in "First name", with: "Alex"
    fill_in "Last name", with: "Brinkman"
    fill_in "Zip code", with: "12345"
    click_button "Save"

    @user.reload
    expect(@user.profile.first_name).to eq("Alex")
    expect(@user.profile.last_name).to eq("Brinkman")
    expect(@user.profile.zip_code).to eq("12345")
  end

end
