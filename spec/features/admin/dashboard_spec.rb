require 'feature_helper'

feature 'Admin visits dashboard' do
  let!(:default_organization) { FactoryBot.create(:default_organization) }
  let(:admin) { FactoryBot.create(:user, :admin) }

  before do
    switch_to_subdomain(admin.organization.subdomain)
    login_as admin
    visit admin_dashboard_index_path
  end

  scenario 'visits sidebar pages' do
    { 'Courses' => admin_root_path,
      'Import DigitalLearn Courses' => admin_import_courses_path,
      'Reports' => admin_reports_path,
      'User Accounts' => admin_users_path,
      'CMS Pages' => admin_pages_path,
      'Invite Admin' => admin_dashboard_admin_invitation_path,
      'Manage Library Branches' => admin_custom_branches_path,
      'Categories' => admin_categories_path,
      'Customizable Text Sections' => admin_custom_translations_path,
      'User Survey' => admin_custom_user_surveys_path,
      'Footer' => admin_custom_footers_path,
      'Login Requirement' => admin_custom_features_path,
      'Manage Programs' => admin_custom_programs_path,
      'Manage Library Branches' => admin_custom_branches_path }.each do |link, path|
      expect(page).to have_link(link)
      click_link(link)
      expect(current_path).to eq(path)
    end
  end

  scenario 'does not see account links' do
    [ 'Profile',
      'Login Information',
      'Completed Courses' ].each do |link|
      expect(page).to_not have_link(link)
    end
  end
end