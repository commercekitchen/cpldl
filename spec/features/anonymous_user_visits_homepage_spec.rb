require "feature_helper"

feature "Anonymous user visits home page" do

  before(:each) do
    @course1 = FactoryGirl.create(:course, title: "Title 1")
    @course2 = FactoryGirl.create(:course, title: "Title 2")
    @course3 = FactoryGirl.create(:course, title: "Title 3")
  end

  scenario "should see all courses in the catelog" do
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
