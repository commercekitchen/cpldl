require "feature_helper"

feature "Admin user clicks through each page" do

  context "courses pages" do

    before(:each) do
      @user = FactoryGirl.create(:user)
      @user.add_role(:admin)
      log_in_with @user.email, @user.password
    end

    scenario "can visit the courses index page and click sidebar links" do
      visit admin_courses_path
      expect(page).to have_content("Courses")

      # Check sidebar links
      within(:css, ".sidebar-links") do
        click_link "Change Login Information"
        # click_link "Update Profile"
        # click_link "Courses"
        # click_link "User Accounts"
      end
    end

  end

end
