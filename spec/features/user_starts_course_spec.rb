require "feature_helper"

feature "User visits course listing page" do

  before(:each) do
    Capybara.default_host = "http://chipublib.example.com"
    @language = FactoryGirl.create(:language)
    @spanish = FactoryGirl.create(:spanish_lang)
    @organization = FactoryGirl.create(:organization)
    @course1 = FactoryGirl.create(:course, title: "Title 1",
                                           course_order: 1,
                                           language: @language,
                                           organization: @organization)
    @course2 = FactoryGirl.create(:course, title: "Title 2",
                                           course_order: 2,
                                           language: @language,
                                           organization: @organization)
    @course3 = FactoryGirl.create(:course, title: "Title 3",
                                           course_order: 3,
                                           language: @language,
                                           organization: @organization)
  end

  context "as an anonymous user" do

    context "courses url version" do

      scenario "should see all courses in the catalog from the homepage" do
        visit courses_path
        expect(page).to have_content(@course1.title)
        expect(page).to have_content(@course2.title)
        expect(page).to have_content(@course3.title)
      end

      scenario "can click on a course to be taken to the course page" do
        visit courses_path
        first(:css, ".course-widget").click
        expect(current_path).to eq(course_path(@course1))
      end

      scenario "can click to start a course and be required to login" do
        visit course_path(@course1)
        click_link "Start Course"
        expect(current_path).to eq(new_user_session_path)
      end

    end

    context "homepage version" do

      scenario "should see all courses in the catalog from the homepage" do
        visit root_path
        expect(page).to have_content(@course1.title)
        expect(page).to have_content(@course2.title)
        expect(page).to have_content(@course3.title)
      end

      scenario "can click on a course to be taken to the course page" do
        visit root_path
        first(:css, ".course-widget").click
        expect(current_path).to eq(course_path(@course1))
      end

    end

  end

  context "as a logged in user" do

    before(:each) do
      @user = FactoryGirl.create(:user)
      @course_with_lessons = FactoryGirl.create(:course_with_lessons)
      @course_progress1 = FactoryGirl.create(:course_progress, course_id: @course_with_lessons.id)
      @user.course_progresses << [@course_progress1]
      login_as(@user)
    end

    scenario "can click to start a course and be taken to the first lesson" do
      visit course_path(@course_with_lessons)
      click_link "Start Course"
      expect(current_path).to eq(course_lesson_path(@course_with_lessons, @course_with_lessons.lessons.first))
    end

    scenario "can click to start a course and be taken to the first not-completed lesson" do
      @completed_lesson1 = FactoryGirl.create(:completed_lesson, lesson_id: @course_with_lessons.lessons.first.id)
      @course_progress1.completed_lessons << @completed_lesson1
      visit course_path(@course_with_lessons)
      click_link "Start Course"
      expect(current_path).to eq(course_lesson_path(@course_with_lessons, @course_with_lessons.lessons.second))
    end

    # scenario "page should pop the modal box when a lesson finishes", js: true do
    #   visit course_path(@course_with_lessons)
    #   click_link "Start Course"
    #   sleep(1) # TODO: There has to be a better way...
    #   execute_script("sendLessonCompleteEvent();"); # TODO: match with event fired from ASL file
    #   sleep(2) # TODO: There has to be a better way?
    #   course_progress = @user.course_progresses.where(course_id: @course_with_lessons.id).first
    #   expect(course_progress.completed_lessons.first.lesson_id).to eq(@course_with_lessons.lessons.first.id)
    # end

  end

end
