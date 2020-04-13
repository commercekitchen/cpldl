# frozen_string_literal: true

require 'feature_helper'

feature 'Admin visits dashboard' do
  let!(:default_organization) { FactoryBot.create(:default_organization) }
  let(:admin) { FactoryBot.create(:user, :admin) }
  let!(:course) { FactoryBot.create(:course, pub_status: 'D', organization: admin.organization) }

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
      'CMS Pages' => admin_cms_pages_path,
      'Invite Admin' => new_user_invitation_path,
      'Manage Library Branches' => admin_library_locations_path,
      'Categories' => admin_categories_path,
      'Custom Text' => admin_custom_translations_path,
      'User Survey' => admin_custom_user_surveys_path,
      'Footer Logo' => admin_custom_footers_path,
      'Login Requirement' => admin_custom_features_path }.each do |link, path|
      expect(page).to have_link(link)
      click_link(link)
      expect(current_path).to eq(path)
      within(:css, '.callout') do
        expect(page).to have_content('Admin Dashboard')
      end
      within(:css, '.main-content') do
        expect(page).to have_css('h2', text: link)
      end
    end
  end

  scenario 'does not see account links' do
    ['Profile',
     'Login Information',
     'Completed Courses'].each do |link|
      expect(page).to_not have_link(link)
    end
  end

  scenario 'changes course publication status', js: true do
    expect(page).to have_select("course_#{course.id}", selected: 'Draft')
    select('Published', from: "course_#{course.id}")
    visit admin_dashboard_index_path
    expect(page).to have_select("course_#{course.id}", selected: 'Published')
  end
end
