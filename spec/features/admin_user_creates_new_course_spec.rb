require "feature_helper"

feature "Admin user creates new course" do

    before(:each) do
      @topic = FactoryGirl.create(:topic)
      @language = FactoryGirl.create(:language)

      @user = FactoryGirl.create(:user)
      @user.add_role(:admin)
      log_in_with @user.email, @user.password
    end

    scenario "properly fills out all required information" do
      visit new_admin_course_path
      expect(page).to have_content("Course Information")
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
      expect(current_path).to eq(edit_admin_course_path(Course.last))
    end

end
