# frozen_string_literal: true

require 'feature_helper'

feature 'Admin manages partners' do
  let(:organization) { FactoryBot.create(:organization, accepts_partners: true) }
  let(:user) { FactoryBot.create(:user, :admin, organization: organization) }

  let!(:partner1) { FactoryBot.create(:partner, organization: organization) }
  let!(:partner2) { FactoryBot.create(:partner, organization: organization) }
  let!(:partner3) { FactoryBot.create(:partner, organization: organization) }

  before do
    switch_to_subdomain(organization.subdomain)
    log_in_with user.email, user.password
  end

  scenario 'admin navigates to partner management page' do
    visit admin_dashboard_index_path
    click_link 'Manage Partners'
    expect(current_path).to eq(admin_partners_path)
  end

  scenario 'admin sees existing partners' do
    visit admin_partners_path
    expect(page).to have_content(partner1.name)
    expect(page).to have_content(partner2.name)
    expect(page).to have_content(partner3.name)
  end

  scenario 'can add a new partner', js: true do
    visit admin_partners_path
    fill_in 'partner_name', with: 'New Partner Name'
    click_on 'Add Partner'
    expect(page).to have_content 'New Partner Name'
    expect(page.find('#partner_name').value).to eq('')
  end

  scenario 'can delete partner', js: true do
    FactoryBot.create(:partner, name: 'test', organization: organization)
    visit admin_partners_path
    page.accept_confirm { click_on "delete_partner_link_#{partner1.id}" }
    expect(page).to_not have_content partner1.name
  end
end
