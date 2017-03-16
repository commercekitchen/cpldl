require "feature_helper"

feature "Admin user clicks through each page" do

  before(:each) do
    @spanish = FactoryGirl.create(:spanish_lang)
    @english = FactoryGirl.create(:language)
    @user = FactoryGirl.create(:user)
    @user.add_role(:admin)
    @organization = FactoryGirl.create(:organization)
    @category = FactoryGirl.create(:category, organization: @user.organization)
    @course = FactoryGirl.create(:course_with_lessons, category: @category)
    @org_course = FactoryGirl.create(:organization_course, organization_id: @user.organization.id, course_id: @course.id)
    @user.add_role(:admin, @organization)
    @user.organization.reload
    switch_to_subdomain("chipublib")
    log_in_with @user.email, @user.password
  end

  scenario "can visit each link in the header" do
    visit admin_dashboard_index_path(subdomain: "chipublib")
    expect(page).to have_content("Hi Admin!")

    visit admin_dashboard_index_path
    within(:css, ".header-logged-in") do
      click_link "Admin Dashboard"
    end
    expect(current_path).to eq(admin_dashboard_index_path)

    visit admin_dashboard_index_path
    within(:css, ".header-logged-in") do
      click_link "Sign Out"
    end
    expect(current_path).to eq(root_path)
    expect(page).to have_content("Signed out successfully.")
  end

end
