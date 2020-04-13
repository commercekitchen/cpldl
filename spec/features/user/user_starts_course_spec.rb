# frozen_string_literal: true

require 'feature_helper'

feature 'User visits course listing page' do
  let(:organization) { FactoryBot.create(:organization) }
  let(:www) { FactoryBot.create(:default_organization) }
  let!(:course1) { FactoryBot.create(:course_with_lessons, title: 'Course 1', course_order: 1, organization: organization) }
  let!(:course2) { FactoryBot.create(:course, title: 'Course 2', course_order: 2, organization: organization) }
  let!(:course3) { FactoryBot.create(:course, title: 'Course 3', course_order: 3, organization: organization) }
  let(:www_course) { FactoryBot.create(:course_with_lessons, organization: www) }

  before(:each) do
    switch_to_subdomain(organization.subdomain)
  end

  context 'as an anonymous user' do
    scenario 'should see all courses in the catalog from the homepage' do
      visit courses_path
      expect(page).to have_content(course1.title)
      expect(page).to have_content(course2.title)
      expect(page).to have_content(course3.title)
    end

    scenario 'can click on a course to be taken to the course page' do
      visit courses_path
      first(:css, '.course-widget').click
      expect(current_path).to eq(course_path(course1))
    end

    scenario 'should see all courses in the catalog from the homepage' do
      visit root_path
      expect(page).to have_content(course1.title)
      expect(page).to have_content(course2.title)
      expect(page).to have_content(course3.title)
    end

    scenario 'can click on a course to be taken to the course page' do
      visit root_path
      first(:css, '.course-widget').click
      expect(current_path).to eq(course_path(course1))
    end

    context 'on a login_required subdomain' do
      scenario 'can click to start a course and is required to sign in' do
        visit course_path(course1)
        click_link 'Start Course'
        expect(current_path).to eq(user_session_path)
      end
    end

    context 'on a non login_required subdomain' do
      scenario 'can click to start a course and is not required to sign in' do
        organization.update(login_required: false)
        visit course_path(course1)
        click_link 'Start Course'
        expect(current_path).to eq(course_lesson_path(course1, course1.lessons.first))
      end
    end

    context 'on www' do
      scenario 'can click to start a course and is not required to sign in' do
        switch_to_subdomain(www.subdomain)
        visit course_path(www_course)
        click_link 'Start Course'
        expect(current_path).to eq(course_lesson_path(www_course, www_course.lessons.first))
      end
    end
  end

  context 'as a logged in user' do
    let(:user) { FactoryBot.create(:user, organization: organization) }
    let!(:course_progress) { FactoryBot.create(:course_progress, course: course1, user: user) }

    before(:each) do
      login_as(user)
    end

    scenario 'can click to start a course and be taken to the first lesson' do
      visit course_path(course1)
      click_link 'Start Course'
      lesson = course1.lessons.first
      expect(current_path).to eq(course_lesson_path(course1, lesson))
      expect(page.title).to eq(lesson.title)
      expect(page).to_not have_selector('h1', text: course1.title)
      expect(page).to have_content("#{lesson.lesson_order}. #{lesson.title}")
    end

    scenario 'can click to start a course and be taken to the first not-completed lesson' do
      FactoryBot.create(:lesson_completion, course_progress: course_progress, lesson: course1.lessons.first)
      visit course_path(course1)
      click_link 'Start Course'
      expect(current_path).to eq(course_lesson_path(course1, course1.lessons.second))
    end

    # scenario "page should pop the modal box when a lesson finishes", js: true do
    #   visit course_path(@course_with_lessons)
    #   click_link "Start Course"
    #   sleep(1) # TODO: There has to be a better way...
    #   execute_script("sendLessonCompleteEvent();"); # TODO: match with event fired from ASL file
    #   sleep(2) # TODO: There has to be a better way?
    #   course_progress = @user.course_progresses.where(course_id: @course_with_lessons.id).first
    #   expect(course_progress.completed_lessons.first.lesson_id).to eq(@course_with_lessons.lessons.first.id)
    # end

  end

end
