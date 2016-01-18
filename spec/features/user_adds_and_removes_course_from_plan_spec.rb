require "feature_helper"

feature "User is able to add and remove a course from their plan" do

  before(:each) do
    @course1 = FactoryGirl.create(:course, title: "Title 1")
    @english = FactoryGirl.create(:language)
    @spanish = FactoryGirl.create(:spanish_lang)
    @user = FactoryGirl.create(:user)
    login_as(@user)
  end

  context "as a logged in user" do

    scenario "can click to add a course to their plan" do
      visit course_path(@course1)
      click_link "Add to your plan"
      expect(current_path).to eq(course_path(@course1))
      expect(page).to have_content("Successfully added this course to your plan.")

      click_link "Remove from your plan"
      expect(current_path).to eq(course_path(@course1))
      expect(page).to have_content("Successfully removed this course to your plan.")
    end

  end

end
