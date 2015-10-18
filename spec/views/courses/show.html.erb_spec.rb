require "rails_helper"

describe "courses/show.html.erb" do

  before(:each) do
    @course = FactoryGirl.create(:course)
    assign(:course, @course)

    @admin = FactoryGirl.create(:admin_user)
    @admin.add_role(:admin)

    @user = FactoryGirl.create(:user)
  end

  context "when logged in as an admin" do

    it "displays the edit course button" do
      sign_in @admin
      render
      expect(rendered).to have_link "Edit Course", href: edit_admin_course_path(@course)
    end
  end

  context "when logged in as a normal user" do

    it "does not display the edit course button" do
      sign_in @user
      render
      expect(rendered).not_to have_content "Edit Course"
    end
  end
end
