# frozen_string_literal: true

require 'feature_helper'

feature 'user signs up for school program' do
  let(:email) { Faker::Internet.free_email }
  let(:password) { Faker::Internet.password }
  let(:first_name) { Faker::Name.first_name }
  let(:last_name) { Faker::Name.last_name }
  let(:zip_code) { Faker::Address.zip }
  let(:organization) { create(:organization, accepts_programs: true) }

  before do
    create(:program, program_name: 'MNPS', parent_type: :students_and_parents, organization: organization)
    create(:school, school_type: :elementary, school_name: 'Lincoln Elementary', organization: organization)
    create(:school, school_type: :middle_school, school_name: 'Middle School East', organization: organization)
    create(:school, school_type: :high_school, school_name: 'GLHS', organization: organization)

  end

  scenario 'registers as student', js: true do
    switch_to_subdomain(organization.subdomain)

    visit login_path
    find('#signup_email').set(email)
    find('#signup_password').set(password)
    find('#user_profile_attributes_first_name').set(first_name)
    find('#user_profile_attributes_last_name').set(last_name)
    find('#user_profile_attributes_zip_code').set(zip_code)
    fill_in 'user_password_confirmation', with: password

    choose('Programs for Students and Parents')

    # School program fields
    expect(page).to have_select('user_program_id', selected: 'MNPS')
    expect(page).to have_select('Parent or Student?', selected: 'Student')
    expect(page).to have_select('School Type', selected: 'Select School Type...')

    expect(page).not_to have_select('School', exact: true)

    # School type selections
    select('Elementary', from: 'School Type')
    expect(page).to have_select('School', exact: true)
    expect(page).to have_select('School', options: ['Select School...', 'Lincoln Elementary'])

    select('Middle School', from: 'School Type')
    expect(page).to have_select('School', options: ['Select School...', 'Middle School East'])

    select('High School', from: 'School Type')
    expect(page).to have_select('School', options: ['Select School...', 'GLHS'])

    select('GLHS', from: 'School')

    fill_in('Student ID', with: '12345')

    click_button 'Sign Up'

    expect(page).to have_content('This is the first time you have logged in, please update your profile.')
  end
end
