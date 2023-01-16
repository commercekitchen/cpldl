# frozen_string_literal: true

require 'feature_helper'

feature 'User visits a subdomain with phone number users enabled' do
  let(:organization) { FactoryBot.create(:organization, login_required: false, phone_number_users_enabled: true) }
  let!(:course) { FactoryBot.create(:course_with_lessons, organization: organization) }

  before do
    switch_to_subdomain(organization.subdomain)
  end

  scenario 'users attempts to take a course and enters phone number' do
    visit root_path
    expect(page).to have_content(course.title)
    find('.course-widget').click
    expect(current_path).to eq(course_path(course))
    click_on('Start Course')
    expect(current_path).to eq(new_phone_number_session_path)

    # Invalid phone number
    fill_in 'Phone Number', with: '1234'
    click_on('Submit')
    expect(current_path).to eq(new_phone_number_session_path)
    expect(page).to have_content('Invalid Phone Number')
    fill_in 'Phone Number', with: '1231231234'
    click_on('Submit')
    expect(current_path).to eq(courses_path(course))
  end

  scenario 'user revisits partially completed course' do
    # create PhoneNumberUser record
    # create CourseProgress attached to PhoneNumberUser & course
    # create LessonCompletion for course
    # set phone number in test session
    # visit course page
    # verify completion
  end
end
