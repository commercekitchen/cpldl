require "feature_helper"

feature "User is able to add and remove a course from their plan" do
  before(:each) do
    switch_to_subdomain("chipublib")
    @org = create(:organization)
    @course1 = create(:course, title: "Title 1")
    @english = create(:language)
    @spanish = create(:spanish_lang)
    @user = create(:user, organization: @org)
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
