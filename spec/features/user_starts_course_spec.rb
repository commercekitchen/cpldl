require "feature_helper"

feature "User visits course listing page" do

  before(:each) do
    @course1 = FactoryGirl.create(:course, title: "Title 1")
    @course2 = FactoryGirl.create(:course, title: "Title 2")
    @course3 = FactoryGirl.create(:course, title: "Title 3")
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

    scenario "can click to start a course and be taken to the first lesson" do
      user = FactoryGirl.create(:user)
      login_as(user)
      visit course_path(@course1)
      click_link "Start Course"
      expect(current_path).to eq(course_lesson_path(@course1, 1))
    end

  end

end
