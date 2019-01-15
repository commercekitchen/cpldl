require "feature_helper"

feature "Admin courses" do
  before(:each) do
    @dpl = create(:organization,
                  subdomain: "dpl",
                  name: "Denver Public Library")
    @www = create(:default_organization)

    @dpl_category = create(:category, organization: @dpl)
    @dpl_disabled_category = create(:category, :disabled, organization: @dpl)
    @www_category = create(:category, organization: @www)
    @www_category_repeat_name = create(:category, name: @dpl_category.name, organization: @www)
    @www_disabled_category = create(:category, :disabled, organization: @www)

    @dpl_course1 = create(:course_with_lessons, organization: @dpl, category: @dpl_category)
    @dpl_course2 = create(:course_with_lessons, organization: @dpl, category: @dpl_category)
    @dpl_course3 = create(:course_with_lessons, organization: @dpl)

    @importable_course1 = create(:course_with_lessons, subsite_course: true, category: @www_category)
    @importable_course2 = create(:course_with_lessons, subsite_course: true, category: @www_category)
    @importable_course3 = create(:course_with_lessons, subsite_course: true, category: @www_category_repeat_name)
    @importable_course4 = create(:course_with_lessons, subsite_course: true)

    @course2 = create(:course_with_lessons, organization: @www, category: @www_category)
    @course3 = create(:course_with_lessons, organization: @www, category: @www_category)
    @course4 = create(:course_with_lessons, organization: @www)

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
      click_link @dpl_course1.title
      expect(current_path).to eq edit_admin_course_path(@dpl_course1)
    end

    scenario "will see edit links in categories" do
      visit admin_root_path
      expect(page).to have_content(@dpl_category.name, count: 1)
    end

    scenario "will see label for disabled courses" do
      visit admin_root_path
      expect(page).to have_content("#{@dpl_disabled_category.name} (disabled)")
    end

    scenario "will see uncategorized section" do
      visit admin_root_path
      expect(page).to have_content("Uncategorized", count: 1)
    end

    scenario "will see importable courses" do
      visit admin_import_courses_path
      expect(page).to have_content(@importable_course1.title)
    end

    scenario "will see importable course links" do
      visit admin_import_courses_path
      expect(page).to have_selector("a[href='#{admin_dashboard_add_imported_course_path(course_id: @importable_course1.id)}']")
    end

    scenario "will see www category headers for importable courses" do
      visit admin_import_courses_path
      expect(page).to have_content(@www_category.name, count: 1)
    end

    scenario "will see label for disabled courses" do
      visit admin_import_courses_path
      expect(page).to have_content("#{@www_disabled_category.name} (disabled)")
    end

    scenario "will see uncategorized header for importable courses" do
      visit admin_import_courses_path
      expect(page).to have_content("Uncategorized", count: 1)
    end

    scenario "wont see repeat links to imported courses on course import page" do
      visit admin_import_courses_path
      expect(page).not_to have_content(@dpl_course1.title)
    end

    scenario "adding a categorized course for new category should create category" do
      visit admin_import_courses_path

      expect do
        find("a[href='#{admin_dashboard_add_imported_course_path(course_id: @importable_course1.id)}']").click
      end.to change(Category, :count).by(1)

      expect(page).to have_content("Course Information")
      expect(page).to have_select("course_category_id", selected: @www_category.name)
    end

    scenario "adding a categorized course for an existing category name should not create category" do
      visit admin_import_courses_path

      expect do
        find("a[href='#{admin_dashboard_add_imported_course_path(course_id: @importable_course3.id)}']").click
      end.not_to change(Category, :count)

      expect(page).to have_content("Course Information")
      expect(page).to have_select("course_category_id", selected: @dpl_category.name)
    end
  end

  context "www admin" do
    before do
      switch_to_subdomain(@www.subdomain)
      login_as(@admin_user)
    end

    scenario "will see edit links in categories" do
      visit admin_root_path
      expect(page).to have_content(@www_category.name, count: 1)
    end

    scenario "will see label for disabled courses" do
      visit admin_root_path
      expect(page).to have_content("#{@www_disabled_category.name} (disabled)")
    end

    scenario "will see uncategorized section" do
      visit admin_root_path
      expect(page).to have_content("Uncategorized", count: 1)
    end

    scenario "can see links to edit courses" do
      visit admin_root_path
      click_link @course2.title
      expect(current_path).to eq edit_admin_course_path(@course2)
    end
  end
end
