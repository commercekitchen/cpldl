# frozen_string_literal: true

require 'feature_helper'

feature 'Admin manages footer links' do
  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, :admin, organization: organization) }

  before do
    switch_to_subdomain(organization.subdomain)
    log_in_with user.email, user.password
  end

  scenario 'admin navigates to footer link page' do
    visit admin_dashboard_index_path
    click_link 'Custom Footer Links'
    expect(current_path).to eq(admin_footer_links_path)
    expect(page).to have_content('Footer Links provide users access to resources outside of DigitalLearn.')
    expect(page).to have_content('These links will appear in addition to any of your subsite\'s CMS Pages in the "LEARN MORE" section of the footer.')
  end

  scenario 'admin sees existing footer links' do
    link = FactoryBot.create(:footer_link, organization: organization)
    visit admin_footer_links_path
    expect(page).to have_content link.label
    expect(page).to have_content link.url
  end

  scenario 'admin can add new footer link', js: true do
    label = 'New External Link'
    url = 'https://example.com'
    visit admin_footer_links_path
    fill_in 'Label', with: label
    fill_in 'URL', with: url
    click_on 'Add Link'
    expect(page).to have_content label
    expect(page).to have_content url
    expect(page).to have_field('Label', with: '')
    expect(page).to have_field('URL', with: '')
  end

  scenario 'admin can delete existing footer link', js: true do
    link = FactoryBot.create(:footer_link, organization: organization)
    visit admin_footer_links_path
    expect(page).to have_content link.label
    expect(page).to have_content link.url
    page.accept_confirm { click_on "delete_footer_link_link_#{link.id}" }
    expect(page).not_to have_content link.label
    expect(page).not_to have_content link.url
  end
end
