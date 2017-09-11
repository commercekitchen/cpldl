require "feature_helper"

feature "User completes course recommendations quiz" do

  before(:each) do
    @english = create(:language)
    @org = create(:organization, subdomain: "www")
    @user = create(:user, organization: @org)

    @core_topic = create(:topic, title: "Core")
    @topic = create(:topic, title: "Government")

    @desktop_course = create(:course, language: @english, format: "D", level: "Intermediate", topics: [@core_topic])
    @mobile_course = create(:course, language: @english, format: "M", level: "Intermediate", topics: [@core_topic])
    @topic_course = create(:course, language: @english, topics: [@topic])

    [@desktop_course, @mobile_course, @topic_course].each do |course|
      create(:organization_course, organization_id: @org.id, course_id: course.id)
    end

    login_as(@user)
  end

  scenario "user completes course recommendations quiz" do
    visit courses_quiz_path
    expect(page).to have_content("what would you like to learn?")
    choose "set_one_2"
    choose "set_two_2"
    choose "set_three_3"

    click_button "Submit"

    expect(current_path).to eq(your_courses_path)
  end
end
