# frozen_string_literal: true

require 'feature_helper'

feature 'Admin updates translations' do
  let(:organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }

  before do
    switch_to_subdomain(organization.subdomain)
    log_in_with admin.email, admin.password
  end

  scenario 'Admin sees correct content on custom translations page' do
    visit admin_custom_translations_path

    # Page Header
    expect(page).to have_content 'Custom Text - English'

    # Table Headers
    expect(page).to have_content 'Section'
    expect(page).to have_content 'Default Text'
    expect(page).to have_content 'Actions'

    # Translation labels
    expect(page).to have_content 'Homepage Greeting'
    expect(page).to have_content 'Course Selection Greeting'
    expect(page).to have_content 'Course Selection Subheader'
    expect(page).to have_content 'Retake the Quiz Button'

    # Translation values
    expect(page).to have_content 'Choose a course below to start learning or search courses.'
    expect(page).to have_content 'Retake the Quiz'
  end

  scenario 'Admin can change a translation' do
    visit admin_custom_translations_path

    find(:xpath, "//tr[td[contains(.,'Course Selection Subheader')]]/td/a", text: 'Edit').click
    expect(current_path).to eq(new_admin_custom_translation_path('en'))

    fill_in 'Course Selection Subheader in English', with: 'New Subheader text'
    click_on 'Submit'

    expect(page).to have_content 'Text for Course Selection Subheader updated.'
    expect(page).to have_content 'New Subheader text'
  end
end
