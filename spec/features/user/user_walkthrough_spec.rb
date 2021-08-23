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

    within('.main-logo') do
      find('a').click
    end
    expect(current_path).to eq(root_path)
    expect(page).to have_content('Choose a course below to start learning')

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

  scenario 'can change their language preference' do
    visit root_path
    expect(page).to have_content('Choose a course below to start learning')

    click_link 'Español'
    expect(current_path).to eq(root_path)
    expect(page).to have_content('Escoja un curso para empezar')
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

  describe 'Footer' do
    let!(:link1) { FactoryBot.create(:footer_link, organization: org) }
    let!(:link2) { FactoryBot.create(:footer_link, organization: org) }
    let!(:other_org_link) { FactoryBot.create(:footer_link) }
    let!(:cms_page) { FactoryBot.create(:cms_page, organization: org, pub_status: 'P') }
    let!(:other_org_cms_page) { FactoryBot.create(:cms_page, pub_status: 'P') }
    let!(:spanish_cms_page) { FactoryBot.create(:cms_page, organization: org, pub_status: 'P', language: @spanish) }
    let!(:spanish_link) { FactoryBot.create(:footer_link, organization: org, language: @spanish) }

    scenario 'english LEARN MORE links display' do
      visit root_path
      expect(page).to have_link(cms_page.title, href: cms_page_path(cms_page))
      expect(page).to have_link(link1.label, href: link1.url)
      expect(page).to have_link(link2.label, href: link2.url)
      expect(page).not_to have_link(other_org_link.label)
      expect(page).not_to have_link(other_org_cms_page.title)
      expect(page).not_to have_link(spanish_cms_page.title)
      expect(page).not_to have_link(spanish_link.label)
    end

    scenario 'spanish LEARN MORE links display' do
      visit root_path
      click_link 'Español'
      expect(page).to have_link(spanish_cms_page.title)
      expect(page).to have_link(spanish_link.label)
      expect(page).not_to have_link(cms_page.title)
      expect(page).not_to have_link(link1.label)
    end
  end

end
