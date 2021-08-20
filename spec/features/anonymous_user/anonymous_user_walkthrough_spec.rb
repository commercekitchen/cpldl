# frozen_string_literal: true

require 'feature_helper'

feature 'Anonymous visits static pages' do
  before do
    create(:default_organization)
  end

  scenario 'visits root path' do
    visit root_path
    expect(page).to have_content('Choose a course below to start learning or search courses.')
  end

  scenario 'visits home page for subdomain with custom translations' do
    org = FactoryBot.create(:organization, subdomain: 'neworg')
    FactoryBot.create(:course, organization: org)
    switch_to_subdomain(org.subdomain)

    header_translation_key = "home.choose_a_course.#{org.subdomain}"
    subhead_translation_key = "home.choose_course_subheader.#{org.subdomain}"
    custom_heading = "Custom Courses Header"
    custom_subheading = "Custom course subheader with more info"
    FactoryBot.create(:translation, locale: :en, key: header_translation_key, value: custom_heading)
    FactoryBot.create(:translation, locale: :en, key: subhead_translation_key, value: custom_subheading)

    visit root_path
    expect(page).to have_content custom_heading
    expect(page).to have_content custom_subheading
  end

  scenario 'visits home page for subdomain with 0 courses' do
    visit root_path
    expect(page).to have_content 'Course materials coming soon.'
  end

  scenario 'can visit the customization page' do
    page = create(:cms_page, title: 'Pricing & Features')
    visit cms_page_path(page)
    expect(current_path).to eq(cms_page_path(page))
  end

  scenario 'can visit the overview page' do
    page = create(:cms_page, title: 'Get DigitalLearn for Your Library')
    visit cms_page_path(page)
    expect(current_path).to eq(cms_page_path(page))
  end

  scenario 'can visit the portfolio page' do
    page = create(:cms_page, title: 'See Our Work In Action')
    visit cms_page_path(page)
    expect(current_path).to eq(cms_page_path(page))
  end

  describe 'Header' do
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
