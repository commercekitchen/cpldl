# frozen_string_literal: true

require 'feature_helper'

feature 'user signs up for school program' do
  let(:email) { Faker::Internet.free_email }
  let(:password) { Faker::Internet.password }
  let(:first_name) { Faker::Name.first_name }
  let(:last_name) { Faker::Name.last_name }
  let(:zip_code) { Faker::Address.zip }
  let(:org) { create(:organization, accepts_programs: true) }

  before do
    create(:program, program_name: 'MNPS', parent_type: :students_and_parents)
    create(:school, school_type: :elementary, school_name: 'Lincoln Elementary')
    create(:school, school_type: :middle_school, school_name: 'Middle School East')
    create(:school, school_type: :high_school, school_name: 'GLHS')
  end

  scenario 'registers', js: true do
    switch_to_subdomain(org.subdomain)

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

    expect(page).not_to have_select('School')

    # School type selections
    select('Elementary', from: 'School Type')
    expect(page).to have_select('School', options: ['Lincoln Elementary'])

    select('Middle School', from: 'School Type')
    expect(page).to have_select('School', options: ['Middle School East'])

    select('High School', from: 'School Type')
    expect(page).to have_select('School', options: ['High School'])

    select('High School', from: 'School')

    fill_in('Student ID', with: '12345')

    expect(page).to have_content('This is the first time you have logged in, please update your profile.')
  end
end
