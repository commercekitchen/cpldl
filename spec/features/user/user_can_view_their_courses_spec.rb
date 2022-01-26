# frozen_string_literal: true

require 'feature_helper'

feature 'User is able to view the courses in their plan' do
  let(:user) { FactoryBot.create(:user) }
  let(:org) { user.organization }
  let(:npl) { FactoryBot.create(:organization, subdomain: 'npl') }
  let(:npl_user) { FactoryBot.create(:user, organization: npl) }
  let(:course1) { FactoryBot.create(:course, title: 'Course 1', organization: org) }
  let(:course2) { FactoryBot.create(:course, title: 'Course 2', organization: org, language: @spanish) }
  let!(:coming_soon_course) { FactoryBot.create(:coming_soon_course, title: 'CS Course', organization: org) }
  let!(:course_progress1) { FactoryBot.create(:course_progress, course: course1, tracked: true, user: user) }
  let!(:course_progress2) { FactoryBot.create(:course_progress, course: course2, tracked: false, user: user) }

  before(:each) do
    switch_to_subdomain(org.subdomain)
    login_as(user)
  end

  context 'as a logged in user' do
    scenario 'can view all courses for current language' do
      visit courses_path
      expect(page).to have_content('Course 1')
      expect(page).to_not have_content('Course 2')

      expect(page).to have_css('.course-widget.coming-soon header h3', text: 'CS Course')
      expect(page).to have_css('.course-widget.coming-soon .description .coming-soon-label', text: 'Coming Soon')
    end

    scenario 'can view matching search results' do
      visit courses_path
      fill_in('Search Courses', with: 'Course')
      find('.icon-button').click
      expect(page).to have_content('Course 1')
    end

    scenario 'can view their added courses' do
      visit my_courses_path
      expect(page).to have_content('Course 1')
      expect(page).to_not have_content('Course 2')
    end

    scenario 'should always have the option to learn more' do
      visit my_courses_path
      expect(page).to have_content('Ready to Learn More?')
      expect(page).to have_content('Find new courses when you retake the quiz')
      expect(page).to have_link('Retake the Quiz')
    end

    scenario 'should not see the more courses blurb' do
      visit my_courses_path
      expect(page).not_to have_content('More courses are available if you sign up')
    end
  end

  context 'npl user' do
    before do
      switch_to_subdomain('npl')
      login_as(npl_user)
    end

    scenario 'should have correct quiz retake button text' do
      visit my_courses_path
      expect(page).to have_link('Add More Courses')
    end
  end
end
