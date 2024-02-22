# frozen_string_literal: true

require 'feature_helper'

feature 'User visits course complete page' do
  let(:user) { FactoryBot.create(:user) }
  let(:org) { user.organization }
  let(:course) { FactoryBot.create(:course, organization: org) }
  let(:survey_url) { 'https://survey.example.com' }
  let(:survey_url_with_uuid) { 'https://survey.example.com?userid=%{user_uuid}' }

  context 'as a logged in user' do
    let!(:course_progress) { FactoryBot.create(:course_progress, user: user, course: course, completed_at: Time.zone.now) }

    before do
      switch_to_subdomain(org.subdomain)
      login_as(user)
      Timecop.freeze(Time.zone.local(2021, 3, 10, 10, 0, 0))
      course_progress.update(completed_at: Time.zone.now)
    end

    after do
      Timecop.return
    end

    scenario 'sees certificate message in english', js: true do
      visit course_completion_path(course)
      message = "This award certifies that\n"\
                "#{user.full_name}\n"\
                "has completed\n"\
                "#{course.title}\n"\
                'as of 3/10/2021'
      expect(page).to have_content(message)
    end

    scenario 'sees organization survey link', js: true do
      org.update(user_survey_enabled: true, user_survey_link: survey_url)
      visit course_completion_path(course)

      survey_link_text = 'We Need Your Help - Please Take a Quick Survey'
      expect(page).to have_link(survey_link_text, href: survey_url)
    end

    scenario 'sees interpolated survey link' do
      org.update(user_survey_enabled: true, user_survey_link: survey_url_with_uuid)
      visit course_completion_path(course)

      survey_link_text = 'We Need Your Help - Please Take a Quick Survey'
      expected_url = "https://survey.example.com?userid=#{user.uuid}"
      expect(page).to have_link(survey_link_text, href: expected_url)
    end

    scenario 'sees certificate message in spanish', js: true do
      visit course_completion_path(course)
      click_link 'Español'

      message = "Este certificado acredita que\n"\
                "#{user.full_name}\n"\
                "ha completado\n"\
                "#{course.title}\n"\
                'el 10/3/2021'
      expect(page).to have_content(message)
    end

    scenario 'sees spanish survey link' do
      org.update(user_survey_enabled: true, user_survey_link: survey_url)
      visit course_completion_path(course)
      click_link 'Español'

      survey_link_text = 'Necesitamos su ayuda - Por favor tome una encuesta rápida'
      
      # Default to english survey url
      expect(page).to have_link(survey_link_text, href: survey_url)

      spanish_survey_url = 'https://spanish-survey.example.com'
      org.update(spanish_survey_link: spanish_survey_url)
      visit course_completion_path(course)

      # Use spanish survey url if available
      expect(page).to have_link(survey_link_text, href: spanish_survey_url)
    end

    scenario 'sees spanish survey link with interpolated value' do
      org.update(user_survey_enabled: true, user_survey_link: survey_url_with_uuid)
      visit course_completion_path(course)
      click_link 'Español'

      survey_link_text = 'Necesitamos su ayuda - Por favor tome una encuesta rápida'
      
      # Default to english survey url
      expected_url = "https://survey.example.com?userid=#{user.uuid}"
      expect(page).to have_link(survey_link_text, href: expected_url)

      spanish_survey_url = 'https://spanish-survey.example.com?userid=%{user_uuid}'
      org.update(spanish_survey_link: spanish_survey_url)
      visit course_completion_path(course)

      # Use spanish survey url if available
      expected_url = "https://spanish-survey.example.com?userid=#{user.uuid}"
      expect(page).to have_link(survey_link_text, href: expected_url)
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
      course.attachments.create(document: file, doc_type: 'additional-resource')
      visit course_completion_path(course)

      click_link 'Use My Skills Now'
      expect(current_path).to eq(course_skills_path(course))
      expect(page).to have_content('testfile.pdf')
    end

    scenario 'can view skills page' do
      file = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'testfile.pdf'), 'application/pdf')
      course.attachments.create(document: file, doc_type: 'additional-resource')
      course.update(notes: '<strong>Post-Course completion notes...</strong>')
      visit course_completion_path(course)
      click_link 'Use My Skills Now'
      expect(current_path).to eq(course_skills_path(course))
      expect(page).to have_content('testfile.pdf')
      expect(page).to have_content('Post-Course completion notes...')
    end

    scenario 'opens custom survey url in a new tab if configured', js: true do
      survey_url = 'https://survey.example.com'
      course.update(survey_url: survey_url)
      visit course_completion_path(course)
      click_link('We Need Your Help - Please Take a Quick Survey')
      expect(page.windows.length).to eq(2)
      new_tab = page.driver.browser.window_handles.last
      page.driver.browser.switch_to.window(new_tab)
      expect(current_url).to match(survey_url)
    end
  end

  context 'as a headless user' do
    before do
      switch_to_subdomain(org.subdomain)
      Timecop.freeze(Time.zone.local(2021, 3, 10, 10, 0, 0))
    end

    after do
      Timecop.return
    end

    scenario 'sees certificate message in english', js: true do
      visit course_completion_path(course)
      message = "This award certifies that\n"\
                "_____________________\n"\
                "has completed\n"\
                "#{course.title}\n"\
                'as of 3/10/2021'
      expect(page).to have_content(message)
    end

    scenario 'sees certificate message in spanish', js: true do
      visit course_completion_path(course)
      click_link 'Español'

      message = "Este certificado acredita que\n"\
                "_____________________\n"\
                "ha completado\n"\
                "#{course.title}\n"\
                'el 10/3/2021'
      expect(page).to have_content(message)
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

    scenario 'can view the additional resources link' do
      file = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'testfile.pdf'), 'application/pdf')
      course.attachments.create(document: file, doc_type: 'additional-resource')
      visit course_completion_path(course)

      click_link 'Use My Skills Now'
      expect(current_path).to eq(course_skills_path(course))
      expect(page).to have_content('testfile.pdf')
    end
  end
end
