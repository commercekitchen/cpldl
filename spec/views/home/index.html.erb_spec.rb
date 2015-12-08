require "rails_helper"

describe "home/index.html.erb" do

  before(:each) do
    @course = FactoryGirl.create(:course)
    @courses = [@course]
    assign(:course, @course)
    @admin = FactoryGirl.create(:admin_user)
    @admin.add_role(:admin)
    @user = FactoryGirl.create(:user)
  end

  context "when logged in as an admin" do
    it "displays the admin message" do
      sign_in @admin
      render
      expect(rendered).to have_content("Edit a course by clicking on a course below,
        search courses or navigate to the Admin Dashboard.")
    end
  end

  context "when logged in as a normal user" do
    it "displays the user message" do
      sign_in @user
      render
      expect(rendered).to have_content("Choose a course below to start learning, search courses, or visit My Courses to view your customized learning plan.")
    end
  end

  context "when not logged in" do
    it "displays the default message" do
      render
      expect(rendered).to have_content("Choose a course below to start learning or search courses.")
    end
  end

end
