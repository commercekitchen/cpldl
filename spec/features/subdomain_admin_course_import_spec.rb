require "feature_helper"

feature "Admin courses" do
  before(:each) do
    @dpl = create(:organization,
                  subdomain: "dpl",
                  name: "Denver Public Library")
    @www = create(:organization, subdomain: "www")
    @course = create(:course_with_lessons, organization: @dpl)
    @importable_course = create(:course_with_lessons, subsite_course: true)
    @course2 = create(:course_with_lessons, organization: @www)
    @dpl_admin_user = create(:user, organization: @dpl)
    @dpl_admin_user.add_role(:admin, @dpl)
    @admin_user = create(:user, organization: @www)
    @admin_user.add_role(:admin, @www)
  end

  context "subdomain admin" do
    before do
      switch_to_subdomain(@dpl.subdomain)
      login_as(@dpl_admin_user)
    end

    scenario "will see links to edit courses on courses page" do
      visit admin_root_path
      click_link @course.title
      expect(current_path).to eq edit_admin_course_path(@course)
    end

    scenario "wont see links to edit courses on course import page" do
      visit admin_import_courses_path
      expect(page).not_to have_selector(:xpath, "/html/body/main/div/div[2]/div[2]/ul/li[1]/div[1]/a")
    end
  end

  context "www admin" do
    before do
      switch_to_subdomain(@www.subdomain)
      login_as(@admin_user)
    end

    scenario "can see links to edit courses" do
      visit admin_root_path
      click_link @course2.title
      expect(current_path).to eq edit_admin_course_path(@course2)
    end
  end
end