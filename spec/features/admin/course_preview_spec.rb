# frozen_string_literal: true

require 'feature_helper'

feature 'Admin previews a PLA course' do
  let(:pla) { FactoryBot.create(:default_organization) }
  let(:subsite_admin) { FactoryBot.create(:user, :admin) }
  let(:org) { subsite_admin.organization }

  let!(:pla_course) { FactoryBot.create(:course_with_lessons, organization: pla) }

  before do
    switch_to_subdomain(org.subdomain)
    login_as subsite_admin
    visit admin_dashboard_index_path
  end

  scenario 'admin clicks course preview link from course import view' do
    click_link 'Import DigitalLearn Courses'
    click_link 'Preview Course'
    expect(current_path).to eq(admin_course_preview_path(pla_course))
    expect(page).to have_content('You are previewing this course.')

    expect(page).to have_link 'Return to Admin Dashboard'
    expect(page).to have_link 'Import'

    expect(page).to_not have_link 'Edit Course >>'

    # Return to import courses view
    click_link 'Return to Admin Dashboard'
    expect(current_path).to eq(admin_import_courses_path)
    click_link 'Preview Course'

    # Course preview
    expect(page).to have_content(pla_course.title)
    pla_course.lessons.each do |lesson|
      expect(page).to have_content(lesson.title)
      expect(page).to have_content(lesson.summary)
    end

    # Lesson preview
    lesson = pla_course.lessons.first
    click_link 'Start Course'
    expect(page).to have_current_path(course_lesson_path(pla_course, lesson, preview: true))
    expect(page).to have_content(lesson.title)
    expect(page).to have_content('You are previewing this course.')

    # Skip to next lesson
    click_link 'Skip to next Activity'
    next_lesson = pla_course.lesson_after(lesson)
    expect(page).to have_current_path(course_lesson_path(pla_course, next_lesson, preview: true))

    # Lesson playlist navigation
    last_lesson = pla_course.lessons.last
    within('.playlist') do
      find('.lesson-title', text: last_lesson.title).ancestor('.lesson-listing_link').click
    end

    expect(page).to have_current_path(course_lesson_path(pla_course, last_lesson, preview: true))
    expect(page).to have_content(last_lesson.title)
    expect(page).to have_content('You are previewing this course.')
  end

  scenario 'admin previews course and clicks lesson tiles' do
    lesson = pla_course.lessons.first
    click_link 'Import DigitalLearn Courses'
    click_link 'Preview Course'
    expect(page).to have_content(lesson.title)
    find('.lesson-title', text: lesson.title).ancestor('.lesson-tile').click
    expect(page).to have_current_path(course_lesson_path(pla_course, lesson, preview: true))
  end

  scenario 'admin finishes lessons in preview mode' do
    first_lesson = pla_course.lessons.first
    second_lesson = pla_course.lessons.second
    last_lesson = pla_course.lessons.last
    last_lesson.update(is_assessment: true)

    visit course_lesson_lesson_complete_path(pla_course, first_lesson, preview: true)
    expect(page).to have_content("You've completed Activity 1: #{first_lesson.title}")

    # Repeat activity link
    click_link 'Repeat Activity'
    expect(page).to have_current_path(course_lesson_path(pla_course, first_lesson, preview: true))

    # Continue link
    visit course_lesson_lesson_complete_path(pla_course, first_lesson, preview: true)
    click_link 'Continue'
    expect(page).to have_current_path(course_lesson_path(pla_course, second_lesson, preview: true))
  end

  scenario 'admin imports course from preview' do
    visit admin_course_preview_path(pla_course.id)
    click_link 'Import'

    new_course = org.courses.where(parent: pla_course).first

    expect(current_path).to eq(edit_admin_course_path(new_course))
  end
end
