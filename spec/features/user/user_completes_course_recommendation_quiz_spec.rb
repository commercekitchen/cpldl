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

  context 'en' do
    scenario 'default questions' do
      visit new_course_recommendation_survey_path
      expect(page).to have_content('what would you like to learn?')
      choose 'desktop_level_Intermediate'
      choose 'mobile_level_Intermediate'
      choose "topic_#{security_topic.id}"

      click_button 'Submit'

      expect(current_path).to eq(my_courses_path)

      expect(page).to have_content(desktop_course.title)
      expect(page).to have_content(mobile_course.title)
      expect(page).to have_content(security_course.title)
      expect(page).not_to have_content(govt_course.title)
    end

    scenario 'custom organization questions' do
      org.update(subdomain: 'getconnected', custom_recommendation_survey: true)

      shopping_topic = FactoryBot.create(:topic, title: 'Online Shopping', translation_key: 'online_shopping', organization: org)
      shopping_course = FactoryBot.create(:course, language: @english, topics: [shopping_topic], organization: org)

      user.update(organization: org)
      switch_to_subdomain('getconnected')
      visit new_course_recommendation_survey_path
      expect(page).to have_content("Can you use a computer to access the Internet? Please choose one option.")
      expect(page).not_to have_content("How comfortable are you with desktop or laptop computers? Select one.")
      expect(page).to have_content("Yes, I know how to use a computer.")
      expect(page).not_to have_content("I can use a computer, but I'd like to learn more.")
      expect(page).to have_content("What do you want to do with a computer or smartphone? Please choose one option.")
      expect(page).to have_content("Make sure I am protected when using the internet.")
      expect(page).to have_content("Shop online.")
    end
  end

  context 'es' do
    scenario 'default questions' do
      Course.all.update(language: @spanish)
      visit new_course_recommendation_survey_path
      click_link 'Español'
      expect(page).to have_content("¿qué le gustaría aprender?")
      choose 'desktop_level_Intermediate'
      choose 'mobile_level_Intermediate'
      choose "topic_#{security_topic.id}"

      click_button 'Enviar'

      expect(current_path).to eq(my_courses_path)

      expect(page).to have_content(desktop_course.title)
      expect(page).to have_content(mobile_course.title)
      expect(page).to have_content(security_course.title)
      expect(page).not_to have_content(govt_course.title)
    end

    scenario 'custom organization questions' do
      org.update(subdomain: 'getconnected', custom_recommendation_survey: true)

      shopping_topic = FactoryBot.create(:topic, title: 'Online Shopping', translation_key: 'online_shopping', organization: org)
      shopping_course = FactoryBot.create(:course, language: @spanish, topics: [shopping_topic], organization: org)

      user.update(organization: org)
      switch_to_subdomain('getconnected')
      Course.all.update(language: @spanish)
      visit new_course_recommendation_survey_path
      click_link 'Español'
      expect(page).to have_content("Can you use a computer to access the Internet? Please choose one option.")
      expect(page).not_to have_content("How comfortable are you with desktop or laptop computers? Select one.")
      expect(page).to have_content("Yes, I know how to use a computer.")
      expect(page).not_to have_content("I can use a computer, but I'd like to learn more.")
      expect(page).to have_content("What do you want to do with a computer or smartphone? Please choose one option.")
      expect(page).to have_content("Make sure I am protected when using the internet.")
      expect(page).to have_content("Shop online.")
    end
  end
end
