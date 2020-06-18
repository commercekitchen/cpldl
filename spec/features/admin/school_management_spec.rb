# frozen_string_literal: true

require 'feature_helper'

feature 'Admin manages schools' do
  let(:organization) { FactoryBot.create(:organization, :accepts_programs) }
  let(:profile) { FactoryBot.create(:profile, :with_last_name) }
  let(:admin) { FactoryBot.create(:user, :admin, profile: profile, organization: organization) }

  before do
    FactoryBot.create(:program, organization: organization, parent_type: :students_and_parents)
    switch_to_subdomain(organization.subdomain)
    log_in_with admin.email, admin.password
  end

  scenario 'Admin view a list of schools' do
    @elementary_school = FactoryBot.create(:school, organization: organization, school_type: 'elementary')
    @middle_school = FactoryBot.create(:school, organization: organization, school_type: 'middle_school')
    @high_school = FactoryBot.create(:school, organization: organization, school_type: 'high_school')

    visit admin_dashboard_index_path
    click_link 'Manage Schools'

    expect(current_path).to eq(admin_schools_path)

    expect(page).to have_content(@elementary_school.school_name)
    expect(page).to have_content(@middle_school.school_name)
    expect(page).to have_content(@high_school.school_name)

    expect(page).to have_select('School type', selected: 'Elementary')
    expect(page).to have_select('School type', selected: 'Middle School')
    expect(page).to have_select('School type', selected: 'High School')
  end

  scenario 'Admin changes a school type', js: true do
    @elementary_school = FactoryBot.create(:school, organization: organization, school_type: 'elementary')

    visit admin_schools_path

    within('.resource-row') do
      select('Middle School', from: 'School type')
    end

    expect(page).to have_select('School type', selected: 'Middle School')

    visit admin_schools_path

    expect(page).to have_select('School type', selected: 'Middle School')
  end

  scenario 'Admin creates a new school', js: true do
    visit admin_schools_path

    fill_in 'School Name', with: 'New School'

    select('Middle School', from: 'school_school_type')
    click_button 'Add School'

    expect(page).to have_selector('.resource-row')
    within('.resource-row') do
      expect(page).to have_content('New School')
      expect(page).to have_select('School type', selected: 'Middle School')
    end
  end
end
