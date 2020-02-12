# frozen_string_literal: true

require 'feature_helper'

feature 'Admin edits subsite programs' do
  let(:organization) { FactoryBot.create(:organization, accepts_programs: true) }
  let(:profile) { FactoryBot.create(:profile, :with_last_name) }
  let(:admin) { FactoryBot.create(:user, :admin, profile: profile, organization: organization) }

  let!(:program1) { FactoryBot.create(:program, organization: organization) }
  let!(:program2) { FactoryBot.create(:program, organization: organization) }
  let!(:other_org_program) { FactoryBot.create(:program) }

  before do
    switch_to_subdomain(organization.subdomain)
    log_in_with admin.email, admin.password
  end

  scenario 'Admin views list of programs' do
    visit admin_dashboard_index_path
    click_link 'Manage Programs'

    expect(current_path).to eq(admin_programs_path)

    expect(page).to have_content(program1.program_name)
    expect(page).to have_content(program2.program_name)
    expect(page).to_not have_content(other_org_program.program_name)

    click_link 'Add New Program'

    expect(current_path).to eq(new_admin_program_path)
    fill_in 'Program Name', with: 'New Program'
    select 'Programs for Seniors'
    page.check('Include Program Locations?')
    click_button 'Create Program'

    expect(current_path).to eq(admin_programs_path)
    expect(page).to have_content('New Program')
  end

end
