# frozen_string_literal: true

require 'feature_helper'

feature 'User completes course recommendations quiz' do

  before(:each) do
    @english = create(:language)
    @org = create(:organization)
    @user = create(:user, organization: @org)

    @core_topic = create(:topic, title: 'Core')
    @topic = create(:topic, title: 'Government')

    @desktop_course = create(:course, language: @english, format: 'D', level: 'Intermediate', topics: [@core_topic], organization: @org)
    @mobile_course = create(:course, language: @english, format: 'M', level: 'Intermediate', topics: [@core_topic], organization: @org)
    @topic_course = create(:course, language: @english, topics: [@topic])

    switch_to_subdomain(@org.subdomain)
    login_as(@user)
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
