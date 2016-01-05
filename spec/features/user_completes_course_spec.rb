require "feature_helper"

feature "User visits course complete page" do

  before(:each) do
    @course1 = FactoryGirl.create(:course, title: "Title 1")
  end

  context "as a logged in user" do

    before(:each) do
      @user = FactoryGirl.create(:user)
      @course = FactoryGirl.create(:course)
      @course_progress = FactoryGirl.create(:course_progress, user_id: @user.id,
                                                              course_id: @course.id,
                                                              completed_at: Time.zone.now)
      login_as(@user)
    end

    scenario "can view the notes and partner resources info for the given course" do
      @course.notes = "<strong>Post-Course completion notes...</strong>"
      @course.save
      visit course_complete_path(@course)
      expect(page).to have_content("Practice and use your new skills! (click each link below)")
      expect(page).to have_content("Post-Course completion notes...")
      expect(page).to_not have_content("<strong>")
    end

    scenario "can view the supplemental materials link" do
      file = fixture_file_upload(Rails.root.join("spec", "fixtures", "testfile.pdf"), "application/pdf")
      @course.attachments.create(document: file, doc_type: "post-course")
      visit course_complete_path(@course)
      expect(page).to have_content("Post-Course Supplemental Materials")
      expect(page).to have_content("testfile.pdf")
    end

  end

end
