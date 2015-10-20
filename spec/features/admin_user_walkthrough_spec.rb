require "feature_helper"

feature "Admin user clicks through each page" do

  context "courses pages" do

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
