# frozen_string_literal: true

require 'feature_helper'

feature 'User clicks through each page' do

  before(:each) do
    create(:default_organization)
    @org = create(:organization)
    @spanish = create(:spanish_lang)
    @english = create(:language)
    @user = create(:user, organization: @org)
    @user.add_role(:user, @org)
    login_as(@user, :scope => :user)
  end

  scenario 'can visit each link in the header' do
    visit root_path
    within(:css, '.header-logged-in') do
      click_link "Hi #{@user.profile.first_name}!"
    end
    expect(current_path).to eq(profile_path)

    visit root_path
    within(:css, '.header-logged-in') do
      click_link 'My Account'
    end
    expect(current_path).to eq(account_path)

    visit root_path
    within(:css, '.header-logged-in') do
      click_link 'My Courses'
    end
    expect(current_path).to eq(my_courses_path)

    visit root_path
    within(:css, '.header-logged-in') do
      click_link 'Sign Out'
    end
    expect(current_path).to eq(root_path)
    expect(page).to have_content('Signed out successfully.')
  end

  scenario 'can visit each link in sidebar' do
    visit profile_path
    within(:css, '.sidebar') do
      click_link 'Change Login Information'
    end
    expect(current_path).to eq(account_path)

    visit profile_path
    within(:css, '.sidebar') do
      click_link 'Update Profile'
    end
    expect(current_path).to eq(profile_path)

    visit profile_path
    within(:css, '.sidebar') do
      click_link 'My Completed Courses'
    end
    expect(current_path).to eq(course_completions_path)
  end

  describe 'Header' do
    let!(:language) { create(:language) }
    let!(:spanish_lang) { create(:spanish_lang) }

    shared_examples 'trainer link' do
      it 'trainer link should exist on landing page' do
        visit root_path
        expect(page).to have_content('Tools and Resources for Trainers')
      end
    end

    context 'under main domain' do
      before do
        switch_to_main_domain
      end
      include_examples 'trainer link'
    end

    context 'under sub domain' do
      let(:dpl) { create(:organization, subdomain: 'dpl', name: 'Denver Public Library') }
      before do
        switch_to_subdomain(dpl.subdomain)
      end
      include_examples 'trainer link'
    end
  end

end
