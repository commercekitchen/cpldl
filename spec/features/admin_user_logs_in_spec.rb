require "feature_helper"

feature "Admin user logs in" do

  context "test forced password changing" do

    before(:each) do
      @user = FactoryGirl.create(:user)
      @user.add_role(:admin)
    end

    scenario "is prompted to change password on first time" do
      expect(@user.sign_in_count).to eq(0)
      log_in_with @user.email, @user.password
      expect(current_path).to eq(profile_path)
      expect(page).to have_content("This is the first time you have logged in, please change your password.")
      click_link "Sign Out"
    end

    scenario "is not prompted to change password after first time" do
      @user.sign_in_count = 1
      @user.save
      log_in_with @user.email, @user.password
      expect(current_path).to eq(admin_dashboard_index_path)
      click_link "Sign Out"
    end

  end

  context "pages walkthrough" do

    before(:each) do
      @user = FactoryGirl.create(:user)
      @user.add_role(:admin)
      log_in_with @user.email, @user.password
    end

    scenario "can visit the courses index page" do
      visit admin_courses_path
      expect(page).to have_content("Listing Courses")
    end

  end

end
