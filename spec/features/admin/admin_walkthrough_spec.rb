# frozen_string_literal: true

require 'feature_helper'

feature 'Admin user clicks through each page' do
  let(:org) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, :admin, organization: org) }

  before(:each) do
    switch_to_subdomain(org.subdomain)
    login_as user
  end

  scenario 'can visit each link in the header' do
    visit admin_dashboard_index_path
    expect(page).to have_content('Hi Admin!')

    click_link 'Dashboard'
    expect(current_path).to eq(admin_dashboard_index_path)

    click_link 'Account'
    expect(current_path).to eq(profile_path)

    click_link 'Sign Out'
    expect(current_path).to eq(root_path)
    expect(page).to have_content('Signed out successfully.')
  end

end
