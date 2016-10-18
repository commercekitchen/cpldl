require "feature_helper"

feature "Admin create a new organization and manages its branches" do
  before(:each) do
    @spanish = create(:spanish_lang)
    @english = create(:language)
    @course = create(:course_with_lessons)
    @www = create(:organization, subdomain: "www")
    @www_admin_user = create(:user, organization: @www)
    @www_admin_user.add_role(:admin, @www)
    switch_to_subdomain("www")
    log_in_with @www_admin_user.email, @www_admin_user.password
  end

  scenario "can create and add admin" do
    visit admin_dashboard_index_path(subdomain: "chipublib")
    expect(page).to have_content("Hi Admin!")

    click_on "Organizations"
    click_on "Add an Organization"
    fill_in :organization_name, with: "Denver Public Library"
    select "Yes", from: :organization_branches
    fill_in :organization_subdomain, with: "dpl"

    click_on "Save Organization"

    expect(page).to have_content("Organization was successfully created.")
    expect(page).to have_content("true")
    click_on "Admin Dashboard"
    click_on "Invite Admin"
    fill_in :user_email, with: "amy@example.com"
    select "Denver Public Library", from: :user_organization_id

    count_before = User.count
    click_on "Send an invitation"
    count_after = User.count
    expect(count_after).to eq(count_before + 1)

    dpl = Organization.find_by(subdomain: 'dpl')
    user = create(:user, organization: dpl)
    user.add_role(:admin, dpl)

    click_on "Admin Dashboard"
    click_on "Organizations"
    expect(page).to have_content("amy@example.com")

    click_link "Sign Out"

    switch_to_subdomain("dpl")
    log_in_with user.email, user.password

    visit admin_dashboard_index_path(subdomain: "dpl")
    click_on "Admin Dashboard"
    click_on "Manage Library Branches"
    click_on "Add a Library Branch"

    fill_in :library_location_name, with: "Ross-Barnum Branch Library"
    fill_in :library_location_zipcode, with: "80223"

    click_on "Save Library Branch"

    expect(page).to have_content("Ross-Barnum Branch Library")
  end

  scenario "branches is only visible when selected yes" do
    visit admin_dashboard_index_path(subdomain: "chipublib")
    expect(page).to have_content("Hi Admin!")

    click_on "Organizations"
    click_on "Add an Organization"
    fill_in :organization_name, with: "Denver Public Library"
    select "No", from: :organization_branches
    fill_in :organization_subdomain, with: "dpl"

    click_on "Save Organization"

    switch_to_subdomain("dpl")
    visit login_path

    expect(page).to have_content("Your Password (must be at least 8 characters)")
    expect(page).not_to have_content("What's your library called?")
  end
end
