require "rails_helper"

describe "home/index.html.erb" do

  before(:each) do
    @org = create(:default_organization)
    allow(view).to receive(:current_organization).and_return(@org)
    allow(view).to receive(:subdomain?).and_return(false)
    allow(view).to receive(:top_level_domain?).and_return(true)
    @course = create(:course)
    @courses = [@course]
    assign(:course, @course)
    @admin = create(:user, :admin, organization: @org)
    @user = create(:user)
  end

  context "when logged in as an admin" do
    it "displays the admin message" do
      sign_in @admin
      render
      expect(rendered).to have_content("Edit a course by clicking on a course below,")
    end
  end

  context "when logged in as a normal user" do
    it "displays the user message" do
      sign_in @user
      render
      expect(rendered).to have_content("Choose a course below to start learning")
    end
  end

  context "when not logged in" do
    it "displays the default message" do
      render
      expect(rendered).to have_content("Choose a course below to start learning or search courses.")
    end
  end

end
