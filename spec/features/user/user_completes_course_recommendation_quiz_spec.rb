# frozen_string_literal: true

require 'feature_helper'

feature 'User completes course recommendations quiz' do
  let(:user) { FactoryBot.create(:user) }
  let(:org) { user.organization }

  let(:core_topic) { FactoryBot.create(:topic, title: 'Core') }
  let(:topic) { FactoryBot.create(:topic, title: 'Government') }

  let(:desktop_course) { FactoryBot.create(:course, language: @english, format: 'D', level: 'Intermediate', topics: [core_topic], organization: org) }
  let(:mobile_course) { FactoryBot.create(:course, language: @english, format: 'M', level: 'Intermediate', topics: [core_topic], organization: org) }
  let(:topic_course) { FactoryBot.create(:course, language: @english, topics: [topic]) }

  before(:each) do
    switch_to_subdomain(org.subdomain)
    login_as(user)
  end

  scenario 'user completes course recommendations quiz' do
    visit new_quiz_response_path
    expect(page).to have_content('what would you like to learn?')
    choose 'set_one_2'
    choose 'set_two_2'
    choose 'set_three_3'

    click_button 'Submit'

    expect(current_path).to eq(my_courses_path)
  end
end
