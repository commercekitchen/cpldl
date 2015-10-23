require "feature_helper"

feature "User clicks through each page" do

  before(:each) do
    @user = FactoryGirl.create(:user)
    log_in_with @user.email, @user.password
  end

  scenario "can visit each link in the header" do
    visit root_path
    within(:css, ".header-logged-in") do
      click_link "Hi User!"
    end
    expect(current_path).to eq(profile_path)

    visit root_path
    within(:css, ".header-logged-in") do
      click_link "Your Account"
    end
    expect(current_path).to eq(account_path)

    visit root_path
    within(:css, ".header-logged-in") do
      click_link "Your Courses"
    end
    expect(current_path).to eq(your_courses_path)

    visit root_path
    within(:css, ".header-logged-in") do
      click_link "Sign Out"
    end
    expect(current_path).to eq(root_path)
    expect(page).to have_content("Signed out successfully.")
  end

  scenario "can visit each link in sidebar" do
    visit profile_path
    within(:css, ".sidebar") do
      click_link "Change Login Information"
    end
    expect(current_path).to eq(account_path)

    visit profile_path
    within(:css, ".sidebar") do
      click_link "Update Profile"
    end
    expect(current_path).to eq(profile_path)

    visit profile_path
    within(:css, ".sidebar") do
      click_link "Your Completed Courses"
    end
    expect(current_path).to eq(completed_courses_path)
  end

end
