# frozen_string_literal: true

require 'feature_helper'

feature 'Admin visits account pages' do
  let(:admin) { FactoryBot.create(:user, :admin) }

  before do
    switch_to_subdomain(admin.organization.subdomain)
    login_as admin
    visit root_path
  end

  scenario 'lands on profile page from Account nav link' do
    click_link 'Account'
    expect(current_path).to eq(profile_path)
  end

  context 'sees correct sidebar options at /account' do
    before { visit account_path }
    it_behaves_like 'User Sidebar Links'
  end

  context 'sees correct sidebar options at /profile' do
    before { visit profile_path }
    it_behaves_like 'User Sidebar Links'
  end

  context 'sees correct sidebar options at /my_courses' do
    before { visit course_completions_path }
    it_behaves_like 'User Sidebar Links'
  end

  scenario 'does not see admin dashboard sidebar' do
    click_link 'Account'
    ['Courses',
     'Import DigitalLearn Courses',
     'Reports',
     'User Accounts',
     'CMS Pages',
     'Invite Admin',
     'Manage Library Branches',
     'Organizations',
     'Categories',
     'Customization'].each do |link|
      expect(page).to_not have_link(link, exact: true)
    end
  end
end
