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

    scenario 'does not see practice skills button if no attachments or notes are available' do
      visit course_completion_path(course)
      expect(page).to_not have_link('Use My Skills Now')
    end

    scenario 'sees practice skills button if notes exist' do
      course.update(notes: '<strong>Post-Course completion notes...</strong>')
      visit course_completion_path(course)

      click_link 'Use My Skills Now'
      expect(current_path).to eq(course_skills_path(course))
      expect(page).to have_content('Post-Course completion notes...')
    end

    scenario 'sees practice skills button if post course attachments exist' do
      file = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'testfile.pdf'), 'application/pdf')
      course.attachments.create(document: file, doc_type: 'post-course')
      visit course_completion_path(course)

      click_link 'Use My Skills Now'
      expect(current_path).to eq(course_skills_path(course))
      expect(page).to have_content('testfile.pdf')
    end

    scenario 'can view skills page' do
      file = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'testfile.pdf'), 'application/pdf')
      course.attachments.create(document: file, doc_type: 'post-course')
      course.update(notes: '<strong>Post-Course completion notes...</strong>')
      visit course_completion_path(course)
      click_link 'Use My Skills Now'
      expect(current_path).to eq(course_skills_path(course))
      expect(page).to have_content('testfile.pdf')
      expect(page).to have_content('Post-Course completion notes...')
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

      click_link 'Use My Skills Now'
      expect(current_path).to eq(course_skills_path(course))
      expect(page).to have_content('Practice and use your new skills!')
      expect(page).to have_content('Post-Course completion notes...')
      expect(page).to_not have_content('<strong>')
    end

    scenario 'can view the supplemental materials link' do
      file = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'testfile.pdf'), 'application/pdf')
      course.attachments.create(document: file, doc_type: 'post-course')
      visit course_completion_path(course)

      click_link 'Use My Skills Now'
      expect(current_path).to eq(course_skills_path(course))
      expect(page).to have_content('testfile.pdf')
    end
  end

end
