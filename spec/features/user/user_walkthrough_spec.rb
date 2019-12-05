# frozen_string_literal: true

require 'feature_helper'

feature 'User clicks through each page' do
  let(:org) { FactoryBot.create(:organization) }
  let(:user) { create(:user, organization: org) }

  before(:each) do
    switch_to_subdomain(org.subdomain)
    login_as(user, scope: :user)
  end

  scenario 'can visit each link in the header' do
    visit root_path
    click_link 'Account'
    expect(current_path).to eq(profile_path)

    click_link 'My Courses'
    expect(current_path).to eq(my_courses_path)
    expect(page).to_not have_link('Profile')

    click_link 'Sign Out'
    expect(current_path).to eq(root_path)
    expect(page).to have_content('Signed out successfully.')
  end

  scenario 'can visit each link in sidebar' do
    visit profile_path
    click_link 'Login Information'
    expect(current_path).to eq(account_path)

    visit profile_path
    click_link 'Profile'
    expect(current_path).to eq(profile_path)

    visit profile_path
    click_link 'Completed Courses'
    expect(current_path).to eq(course_completions_path)
  end

  describe 'Header' do
    shared_examples 'trainer link' do
      it 'trainer link should exist on landing page' do
        visit root_path
        expect(page).to have_content('Tools and Resources for Trainers')
      end
    end

    context 'under main domain' do
      let(:default_org) { FactoryBot.create(:default_organization) }

      before do
        switch_to_subdomain(default_org.subdomain)
      end
      include_examples 'trainer link'
    end

    context 'under sub domain' do
      let(:dpl) { FactoryBot.create(:organization, subdomain: 'dpl', name: 'Denver Public Library') }

      before do
        switch_to_subdomain(dpl.subdomain)
      end
      include_examples 'trainer link'
    end
  end

end
