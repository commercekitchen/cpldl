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
    expect(current_path).to eq(admin_course_preview_path(pla_course.id))
    expect(page).to have_content("Previewing course: \"#{pla_course.title}\".")

    expect(page).to have_link 'Return to Admin Panel'
    expect(page).to have_link 'Import Course'

    expect(page).to_not have_link 'Edit Course >>'

    # Return to import courses view
    click_link 'Return to Admin Panel'
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
    expect(page).to have_content("Previewing course: \"#{pla_course.title}\".")

    # Lesson playlist navigation

    # Preview from lesson tiles

    # Completing course

  end
end
