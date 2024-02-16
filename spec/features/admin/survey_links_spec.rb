# frozen_string_literal: true

require 'feature_helper'

feature 'Admin updates organization survey links' do
  let(:organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  
  before do
    switch_to_subdomain(organization.subdomain)
    log_in_with admin.email, admin.password
  end

  scenario 'Admin sees correct content' do
    visit admin_custom_user_surveys_path

    expect(page).to have_content('User Survey')

    subheader_content = 'Add a button that will appear on all course '\
                        'completion pages to take your users to an external '\
                        'survey site of your choice.'

    expect(page).to have_content(subheader_content)
    expect(page).to have_field('Enable Survey?', checked: false)
    expect(page).to have_content('Survey Button Text')

    default_english_text = 'We Need Your Help - Please Take a Quick Survey'
    expect(page).to have_field('English', with: default_english_text)

    default_spanish_text = 'Necesitamos su ayuda - Por favor tome una encuesta rápida'
    expect(page).to have_field('Spanish', with: default_spanish_text)
    
    expect(page).to have_field('Survey Link')
    expect(page).to have_field('Spanish Survey Link')

    english_default_warning = 'If a Spanish language survey link is not provided, '\
                              'the English survey will be used by default.'
    expect(page).to have_content(english_default_warning)
  end

  scenario 'Admin sees correct error when entering invalid URL' do
    visit admin_custom_user_surveys_path

    page.check('Enable Survey?')
    expect(page).to have_field('Enable Survey?', checked: true)

    survey_url = 'https://survey.example.com'
    fill_in 'Survey Link', with: survey_url
    click_on('Submit')

    expect(page).to have_field('Survey Link', with: survey_url)

    fill_in 'Spanish Survey Link', with: survey_url
    click_on('Submit')

    expect(page).to have_field('Spanish Survey Link', with: survey_url)
  end
end
