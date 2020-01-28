# frozen_string_literal: true

require 'feature_helper'

feature 'User visits course complete page' do
  let(:user) { FactoryBot.create(:user) }
  let(:org) { user.organization }
  let(:course) { FactoryBot.create(:course, organization: org) }

  context 'as a logged in user' do
    let!(:course_progress) { FactoryBot.create(:course_progress, user: user, course: course, completed_at: Time.zone.now) }

    before do
      switch_to_subdomain(org.subdomain)
      login_as(user)
    end

    scenario 'can view the notes and partner resources info for the given course' do
      course.notes = '<strong>Post-Course completion notes...</strong>'
      course.save
      visit course_completion_path(course)
      expect(page).to have_content('Practice and use your new skills! (click each link below)')
      expect(page).to have_content('Post-Course completion notes...')
      expect(page).to_not have_content('<strong>')
    end

    scenario 'can view the supplemental materials link' do
      file = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'testfile.pdf'), 'application/pdf')
      course.attachments.create(document: file, doc_type: 'post-course')
      visit course_completion_path(course)
      expect(page).to have_content('testfile.pdf')
    end

  end

  context 'as a headless user' do
    let!(:course_progress) { FactoryBot.create(:course_progress, course: course, completed_at: Time.zone.now) }

    before do
      switch_to_subdomain(org.subdomain)
    end

    scenario 'can view the notes and partner resources info for the given course' do
      course.notes = '<strong>Post-Course completion notes...</strong>'
      course.save
      visit course_completion_path(course)
      expect(page).to have_content('Practice and use your new skills! (click each link below)')
      expect(page).to have_content('Post-Course completion notes...')
      expect(page).to_not have_content('<strong>')
    end

    scenario 'can view the supplemental materials link' do
      file = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'testfile.pdf'), 'application/pdf')
      course.attachments.create(document: file, doc_type: 'post-course')
      visit course_completion_path(course)
      # expect(page).to have_content("Click here for a text copy of the course.")
      expect(page).to have_content('testfile.pdf')
    end
  end

end
