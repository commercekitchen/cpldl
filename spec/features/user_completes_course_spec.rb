require "feature_helper"

feature "User visits course complete page" do

  before(:each) do
    @course1 = FactoryGirl.create(:course, title: "Title 1")
  end

  context "as a logged in user" do

    before(:each) do
      @user = FactoryGirl.create(:user)
      @course = FactoryGirl.create(:course)
      login_as(@user)
    end

    scenario "can view the notes and partner resources info for the given course" do
      @course.notes = "<strong>Post-Course completion notes...</strong>"
      @course.save
      visit course_complete_path(@course)
      expect(page).to have_content("Notes and Partner Resources")
      expect(page).to have_content("Post-Course completion notes...")
      expect(page).to_not have_content("<strong>")
    end

    scenario "can view the supplemental materials link" do
      visit course_complete_path(@course)
      expect(page).to have_content("Post-Course Supplemental Materials")
      expect(page).to have_content("This is a PDF of the Course")
    end

  end

end
