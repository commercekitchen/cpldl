# frozen_string_literal: true

require 'feature_helper'

feature 'Subdomain admin program management' do

  before(:each) do
    @spanish = create(:spanish_lang)
    @english = create(:language)
    @dpl = create(:organization, :accepts_programs, subdomain: 'dpl')
    valid_profile = create(:profile, :with_last_name)
    @dpl_admin = create(:user, organization: @dpl, profile: valid_profile)
    @dpl_admin.add_role(:admin, @dpl)
    switch_to_subdomain('dpl')
    log_in_with @dpl_admin.email, @dpl_admin.password
  end

  scenario 'subdomain admin can manage program locations' do
    program = create(:program, :location_required, organization: @dpl)
    program_location1 = create(:program_location, program: program)
    program_location2 = create(:program_location, program: program)
    program_location3 = create(:program_location, program: program)
    visit admin_dashboard_index_path(subdomain: 'dpl')
    click_on 'Admin Dashboard'
    click_on 'Manage Programs'
    expect(page).to have_selector("a[href='/admin/programs/#{program.id}/edit']")
    find("a[href='/admin/programs/#{program.id}/edit']").click
    expect(page).to have_link('Disable', count: 3)
    expect(page).to have_button('Add')
  end
end
