# frozen_string_literal: true

require 'feature_helper'

feature 'Admin user updates lesson' do
  let(:story_line) do
    fixture_file_upload(Rails.root.join('spec', 'fixtures', 'BasicSearch1.zip'), 'application/zip')
  end

  let(:pla) { FactoryBot.create(:default_organization) }

  let(:course) { FactoryBot.create(:course, organization: pla) }
  let(:lesson) { FactoryBot.create(:lesson, course: course) }

  let(:user) { FactoryBot.create(:user, :admin, organization: pla) }

  before do
    switch_to_subdomain(pla.subdomain)
    log_in_with user.email, user.password
  end

  scenario 'can change lesson attachment', js: true do
    visit edit_admin_course_lesson_path(course, lesson)
    expect(page).to have_content('BasicSearch1.zip')
    accept_confirm do
      click_link 'Remove'
    end
    expect(page).not_to have_content('BasicSearch1.zip')
    expect(page).to have_content('Story Line successfully removed, please upload a new story line .zip file.')

    # Re-attach file
    attach_file 'Articulate Storyline Package', Rails.root.join('spec', 'fixtures', 'BasicSearch1.zip')
    click_button 'Save Lesson'

    expect(current_path).to eq(edit_admin_course_lesson_path(course.to_param, Lesson.last.to_param))
    expect(page).to have_content('Lesson successfully updated.')
  end
end
