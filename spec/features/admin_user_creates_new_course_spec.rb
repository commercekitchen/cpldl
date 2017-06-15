require "feature_helper"

feature "Admin user creates new course and lesson" do

  before(:each) do
    @topic = FactoryGirl.create(:topic)
    @spanish = FactoryGirl.create(:spanish_lang)
    @story_line = Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/BasicSearch1.zip"), "application/zip")
    
    @organization = FactoryGirl.create(:organization)
    @user = FactoryGirl.create(:user, organization: @organization)
    @category = FactoryGirl.create(:category, organization: @organization)
    @disabled_category = FactoryGirl.create(:category, :disabled, organization: @organization)

    @user.add_role(:admin, @organization)
    switch_to_subdomain("chipublib")
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
      select("Desktop", from: "course_format")
      select("English", from: "course_language_id")
      select("Beginner", from: "course_level")
      select("Published", from: "course_pub_status")
      click_button "Save Course"
    end
    expect(current_path).to eq(edit_admin_course_path(Course.last))
  end

  scenario "creates new category with course" do
    visit new_admin_course_path
    within(:css, "main") do
      fill_in :course_title, with: "New Course Title"
      fill_in :course_contributor, with: "Jane Doe"
      fill_in :course_summary, with: "Summary for new course"
      fill_in :course_description, with: "Description for new course"
      check "Topic A"
      check "Other Topic"
      fill_in :course_other_topic_text, with: "Some New Topic"
      select("Create new category", from: "course_category_id")
      fill_in :course_category_attributes_name, with: Faker::Lorem.word
      select("Desktop", from: "course_format")
      select("English", from: "course_language_id")
      select("Beginner", from: "course_level")
      select("Published", from: "course_pub_status")
      click_button "Save Course"
    end
    expect(current_path).to eq(edit_admin_course_path(Course.last))
    expect(page).to have_select("course_category_id", selected: Course.last.category.name)
  end

  scenario "creates new course with existing category" do
    visit new_admin_course_path
    within(:css, "main") do
      fill_in :course_title, with: "New Course Title"
      fill_in :course_contributor, with: "Jane Doe"
      fill_in :course_summary, with: "Summary for new course"
      fill_in :course_description, with: "Description for new course"
      check "Topic A"
      check "Other Topic"
      fill_in :course_other_topic_text, with: "Some New Topic"
      select(@category.name, from: "course_category_id")
      select("Desktop", from: "course_format")
      select("English", from: "course_language_id")
      select("Beginner", from: "course_level")
      select("Published", from: "course_pub_status")
      click_button "Save Course"
    end
    expect(page).to have_content("Course was successfully created.")
    expect(current_path).to eq(edit_admin_course_path(Course.last))
    expect(page).to have_select("course_category_id", selected: @category.name)
  end

  scenario "can see which categories are disabled" do
    visit new_admin_course_path
    expect(page).to have_select("course_category_id", with_options: ["#{@category.name}", "#{@disabled_category.name} (disabled)"])
  end

  scenario "attempts to create duplicate category" do
    @category = FactoryGirl.create(:category, organization: @organization)
    @organization.reload

    visit new_admin_course_path
    within(:css, "main") do
      fill_in :course_title, with: "New Course Title"
      fill_in :course_contributor, with: "Jane Doe"
      fill_in :course_summary, with: "Summary for new course"
      fill_in :course_description, with: "Description for new course"
      check "Topic A"
      check "Other Topic"
      fill_in :course_other_topic_text, with: "Some New Topic"
      select("Create new category", from: "course_category_id")
      fill_in :course_category_attributes_name, with: @category.name
      select("Desktop", from: "course_format")
      select("English", from: "course_language_id")
      select("Beginner", from: "course_level")
      select("Published", from: "course_pub_status")
      click_button "Save Course"
    end
    expect(page).to have_content("Category Name is already in use by your organization.")
    expect(page).to have_select("course_category_id", selected: "Create new category")
    expect(page).to have_selector(:css, ".field_with_errors #course_category_attributes_name[value='#{@category.name}']")
  end

  pending "Admin should be able to add both course supl materials and post-course supl materials"

  #file uploader is the issue here
  pending "adds a lesson" do
    @course = create(:course)
    visit edit_admin_course_path(course_id: @course, id: @course.id)
    click_button "Save Course and Add Lessons"
    expect(current_path).to eq(new_admin_course_lesson_path(@course))
    within(:css, "main") do
      fill_in :lesson_title, with: "New Lesson Title"
      fill_in :lesson_summary, with: "Summary for new lesson"
      fill_in :lesson_duration, with: "05:15"
      File.open('spec/fixtures/BasicSearch1.zip') { |file| @story_line.upload = file }
      click_button "Save Lesson"
    end
    expect(current_path).to eq(edit_admin_course_lesson_path(@course, Lesson.last))
  end
end
