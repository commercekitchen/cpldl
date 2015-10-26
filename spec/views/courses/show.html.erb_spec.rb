require "rails_helper"

describe "courses/show.html.erb" do

  before(:each) do
    @course = FactoryGirl.create(:course, meta_desc: "Meta description.", seo_page_title: "SEO Title")
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

  context "as logged out user (and search engine)" do
    it "uses the meta_desc field as a meta description tag" do
      render template: "courses/show", layout: "layouts/application"
      expect(rendered).to have_selector("meta[name='description'][content='Meta description.']", visible: false)
    end

    it "uses the course summary field as the meta description tag if the seo_page_title is blank" do
      @course.meta_desc = ""
      render template: "courses/show", layout: "layouts/application"
      expect(rendered).to have_selector("meta[name='description'][content='In this course you will...']", visible: false)
    end

    it "uses the seo title if available" do
      render template: "courses/show", layout: "layouts/application"
      expect(rendered).to have_selector("title", text: "SEO Title", visible: false)
    end

    it "uses the course title if seo title is not available" do
      @course.seo_page_title = ""
      render template: "courses/show", layout: "layouts/application"
      expect(rendered).to have_selector("title", text: "Computer Course", visible: false)
    end

    it "respects html formatting of the body" do
      @course.description = "<strong>Should display in bold</strong>"
      render
      expect(rendered).to have_selector("p strong", text: "Should display in bold")
    end
  end
end
