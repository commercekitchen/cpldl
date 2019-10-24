require 'feature_helper'

RSpec.shared_examples 'User Sidebar Links' do
  scenario 'contains correct links' do
    expect(page).to have_link('Profile')
    expect(page).to have_link('Login Information')
    expect(page).to have_link('Completed Courses')
  end
end

feature 'Admin visits account pages' do
  let(:admin) { FactoryBot.create(:user, :admin) }

  before do
    @english = create(:language)
    @spanish = create(:spanish_lang)
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
    before { visit my_courses_path }
    it_behaves_like 'User Sidebar Links'
  end

  scenario 'does not see admin dashboard sidebar' do
    click_link 'Account'
    expect(page).to_not have_link('Courses', exact: true)
    expect(page).to_not have_link('Reports')
    expect(page).to_not have_link('User Accounts')
    expect(page).to_not have_link('CMS Pages')
    expect(page).to_not have_link('Invite Admin')
    expect(page).to_not have_link('Organizations')
    expect(page).to_not have_link('Categories')
    expect(page).to_not have_link('Customization')
  end
end
