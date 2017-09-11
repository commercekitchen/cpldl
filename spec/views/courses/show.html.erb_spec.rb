require "rails_helper"

describe "courses/show.html.erb" do

  before(:each) do
    @org = create(:organization, subdomain: "www")
    allow(view).to receive(:current_organization).and_return(@org)
    allow(view).to receive(:subdomain?).and_return(false)
    @course = create(:course, meta_desc: "Meta description.", seo_page_title: "SEO Title")
    assign(:course, @course)
    @admin = create(:admin_user)
    @admin.add_role(:admin, @org)
    @user = create(:user, organization: @org)
    @course_progress1 = create(:course_progress, course_id: @course.id)
    @user.course_progresses << [@course_progress1]
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

    it "shows the 'Add to your plan' link if the course is not currently tracked" do
      sign_in @user
      @course_progress1.tracked = true
      @course_progress1.save
      render
      expect(rendered).to_not have_link "Add to your plan"
      expect(rendered).to have_link "Remove from your plan"
    end

    it "shows the 'Remove from your plan' link if the course is not currently tracked" do
      sign_in @user
      @course_progress1.tracked = false
      @course_progress1.save
      render
      expect(rendered).to have_link "Add to your plan"
      expect(rendered).to_not have_link "Remove from your plan"
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
      expect(rendered).to have_selector("title", text: @course.title, visible: false)
    end

    it "respects html formatting of the body" do
      @course.description = "<strong>Should display in bold</strong>"
      render
      expect(rendered).to have_selector("strong", text: "Should display in bold")
    end

    it "does not show the 'Add to your plan' or 'Remove from your plan' link" do
      render
      expect(rendered).to_not have_link "Add to your plan"
      expect(rendered).to_not have_link "Remove from your plan"
    end
  end
end
