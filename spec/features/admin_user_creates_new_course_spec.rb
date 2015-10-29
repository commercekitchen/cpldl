require "feature_helper"

feature "Admin user creates new course and lesson" do

  before(:each) do
    @course = FactoryGirl.create(:course)
    @topic = FactoryGirl.create(:topic)

    @story_line = Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/BasicSearch1.zip"), "application/zip")

    @user = FactoryGirl.create(:user)
    @user.add_role(:admin)
    log_in_with @user.email, @user.password
  end

  scenario "fills out course required information" do
    visit new_admin_course_path
    expect(page).to have_content("Course Information")
    within(:css, "main") do
      fill_in :course_title, with: "New Course Title"
      fill_in :course_contributor, with: "Jane Doe"
      fill_in :course_summary, with: "Summary for new course"
      fill_in :course_description, with: "Description for new course"
      check "Topic A"
      check "Other Topic"
      fill_in :course_other_topic_text, with: "Some New Topic"
      select("English", from: "course_language_id")
      select("Beginner", from: "course_level")
      select("Published", from: "course_pub_status")
      click_button "Save Course"
    end
    expect(current_path).to eq(edit_admin_course_path(Course.last))
  end

  # FIXME: need to mock file upload
  scenario "adds a lesson" do
    visit edit_admin_course_path(course_id: @course, id: 1)
    click_button "Save Course and Edit Lessons"
    expect(current_path).to eq(new_admin_course_lesson_path(@course))
    within(:css, "main") do
      fill_in :lesson_title, with: "New Lesson Title"
      fill_in :lesson_summary, with: "Summary for new lesson"
      fill_in :lesson_duration, with: "05:15"
      File.open("spec/fixtures/BasicSearch1.zip") { |file| @story_line.upload = file }
      click_button "Save Lesson"
    end
    expect(current_path).to eq(edit_admin_course_lesson_path(@course, Lesson.last))
  end

end
