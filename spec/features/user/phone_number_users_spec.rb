# frozen_string_literal: true

require 'feature_helper'

feature 'User visits a subdomain with phone number users enabled' do
  let(:organization) { FactoryBot.create(:organization, phone_number_users_enabled: true) }
  let(:phone_number) { '1231231234' }
  let!(:user) { create(:phone_number_user, sign_in_count: 2, phone_number: phone_number, organization: organization) }
  let(:topic) {  FactoryBot.create(:topic, title: 'Search For a Job.', translation_key: 'job_search') }
  let!(:course) { FactoryBot.create(:course_with_lessons, organization: organization, topics: [topic]) }
  let(:lesson) { course.lessons.first }

  before do
    switch_to_subdomain(organization.subdomain)
  end

  scenario 'users attempts to take a course and enters phone number' do
    visit root_path
    expect(page).to have_content(course.title)
    find('.course-widget').click
    expect(current_path).to eq(course_path(course))
    click_on('Start Course')
    expect(current_path).to eq(new_user_session_path)

    # Invalid phone number
    fill_in 'Phone Number', with: '1234'
    click_on('Submit')
    expect(current_path).to eq(new_user_session_path)
    expect(page).to have_content('Phone Number must be exactly 10 digits')

    # Valid phone number
    fill_in 'Phone Number', with: phone_number
    click_on('Submit')
    expect(current_path).to eq(course_lesson_path(course, lesson))
  end

  scenario 'user revisits partially completed course' do
    course_progress = FactoryBot.create(:course_progress, user: user, course: course)
    FactoryBot.create(:lesson_completion, course_progress: course_progress, lesson: lesson)

    # Sign in with phone number
    visit new_user_session_path
    fill_in 'Phone Number', with: phone_number
    click_on('Submit')
    expect(current_path).to eq(root_path)
    expect(page).to have_content('33% Complete')

    find('.course-widget').click
    expect(current_path).to eq(course_path(course))

    expect(page).to have_selector('.lesson-tile.completed')
  end

  scenario 'user views account page' do
    # Sign in with phone number
    visit new_user_session_path
    fill_in 'Phone Number', with: phone_number
    click_on('Submit')

    # Verify greetings
    within('.header-nav') do
      expect(page).to have_content('Hi (123) 123-1234!')
    end

    within('.banner') do
      expect(page).to have_content('Hi (123) 123-1234!')
    end
    
    # Default account page
    click_link('Account')
    expect(current_path).to eq(course_completions_path)
    
    # Should not have profile or login options
    expect(page).not_to have_link('Profile')
    expect(page).not_to have_link('Login Information')
  end

  scenario 'user logs out' do
    # Sign in with phone number
    visit new_user_session_path
    fill_in 'Phone Number', with: phone_number
    click_on('Submit')

    # Sign out
    click_link('Sign Out')
    expect(page).to have_content('Signed out successfully.')
    expect(current_path).to eq(root_path)
    expect(page).not_to have_link('Account')
    expect(page).to have_link('Sign Up / Log In')
  end

  scenario 'user signs in for first time' do
    # Sign in with phone number
    visit new_user_session_path
    fill_in 'Phone Number', with: '1112223333'
    click_on('Submit')

    expect(current_path).to eq(new_course_recommendation_survey_path)
    expect(page).to have_content('(111) 222-3333, what would you like to learn?')

    choose('desktop_level_Intermediate')
    choose('mobile_level_Intermediate')
    choose("topic_#{topic.id}")

    click_button 'Submit'

    expect(current_path).to eq(my_courses_path)

    # Retake quiz
    find('.retake-quiz').click

    expect(current_path).to eq(new_course_recommendation_survey_path)
    expect(page).to have_content('(111) 222-3333, what would you like to learn?')

    choose('desktop_level_Beginner')
    choose('mobile_level_Advanced')
    choose("topic_#{topic.id}")

    click_button 'Submit'

    expect(current_path).to eq(my_courses_path)
  end
end
