# frozen_string_literal: true

require 'feature_helper'

feature 'User completes course recommendations quiz' do
  let(:user) { FactoryBot.create(:user) }
  let(:org) { user.organization }

  let(:core_topic) { FactoryBot.create(:topic, title: 'Core') }
  let(:govt_topic) { FactoryBot.create(:topic, title: 'Govt', translation_key: 'govt') }
  let(:security_topic) { FactoryBot.create(:topic, title: 'Security', translation_key: 'security') }
  let!(:desktop_course) { FactoryBot.create(:course, language: @english, format: 'D', level: 'Intermediate', topics: [core_topic], organization: org) }
  let!(:mobile_course) { FactoryBot.create(:course, language: @english, format: 'M', level: 'Intermediate', topics: [core_topic], organization: org) }
  let!(:govt_course) { FactoryBot.create(:course, language: @english, topics: [govt_topic], organization: org) }
  let!(:security_course) { FactoryBot.create(:course, language: @english, topics: [security_topic], organization: org) }

  before(:each) do
    switch_to_subdomain(org.subdomain)
    login_as(user)
  end

  scenario 'user completes course recommendations quiz' do
    visit new_course_recommendation_survey_path
    expect(page).to have_content('what would you like to learn?')
    choose 'desktop_level_Intermediate'
    choose 'mobile_level_Intermediate'
    find("input[type='checkbox'][value='#{govt_topic.id}']").click
    find("input[type='checkbox'][value='#{security_topic.id}']").click

    click_button 'Submit'

    expect(current_path).to eq(my_courses_path)

    expect(page).to have_content(desktop_course.title)
    expect(page).to have_content(mobile_course.title)
    expect(page).to have_content(govt_course.title)
    expect(page).to have_content(security_course.title)
  end
end
