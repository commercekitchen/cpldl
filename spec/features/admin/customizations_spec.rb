require 'feature_helper'

feature 'Subsite admin customizes organization' do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, organization: organization) }

  before do
    switch_to_subdomain(organization.subdomain)
    login_as user
    visit admin_dashboard_index_path
  end

  scenario 'visits customization pages' do
    click_link 'Customization'
    expect(current_path).to eq(admin_custom_translations_path)
    { 'Customizable Text Sections' => admin_custom_translations_path,
      'User Survey' => admin_custom_user_surveys_path,
      'Footer' => admin_custom_footers_path,
      'Login Requirement' => admin_custom_features_path,
      'Manage Programs' => admin_custom_programs_path,
      'Manage Library Branches' => admin_custom_branches_path }.each do |link, path|
      expect(page).to have_link(link)
      click_link(link)
      expect(current_path).to eq(path)
    end
  end

  scenario 'manages programs' do
    visit admin_custom_programs_path
    expect(page).to have_selector('h1', text: 'Manage Programs')
  end

  scenario 'manages branches' do
    visit admin_custom_branches_path
    expect(page).to have_selector('h1', text: 'Manage Library Branches')
  end

end
