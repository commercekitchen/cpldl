require "feature_helper"

feature "User visits course complete page" do

  before(:each) do
    @org = create(:organization)
    create(:organization, subdomain: "www")
    @course1 = create(:course, title: "Title 1")
    @english = create(:language)
    @spanish = create(:spanish_lang)
  end

  context "as a logged in user" do
    before(:each) do
      @user = create(:user, organization: @org )
      @course = create(:course)
      @course_progress = create(:course_progress, user_id: @user.id,
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
      expect(page).to have_content("testfile.pdf")
    end

  end

  context "as a headless user" do
    before(:each) do
      @course = create(:course)
      @course_progress = create(:course_progress, course_id: @course.id,
                                                              completed_at: Time.zone.now)
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
      # expect(page).to have_content("Click here for a text copy of the course.")
      expect(page).to have_content("testfile.pdf")
    end
  end

end
