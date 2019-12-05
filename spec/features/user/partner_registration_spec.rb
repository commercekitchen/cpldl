# frozen_string_literal: true

require 'feature_helper'

feature 'User registers and selects a partner' do
  let(:partner) { FactoryBot.create(:partner) }
  let(:organization) { partner.organization }
  let(:email) { Faker::Internet.free_email }
  let(:password) { Faker::Internet.password }
  let(:first_name) { Faker::Name.first_name }

  scenario 'user registers', js: true do
    switch_to_subdomain(organization.subdomain)

    visit login_path
    fill_in 'signup_email', with: email
    fill_in 'signup_password', with: password
    fill_in 'user_profile_attributes_first_name', with: first_name
    fill_in 'user_password_confirmation', with: password

    click_button 'Sign Up'

    expect(current_path).to eq(login_path)

    select partner.name, from: 'Where did you find out about DigitalLearn?'

    click_button 'Sign Up'

    expect(current_path).to eq(profile_path)
    expect(User.last.reload.partner).to eq(partner)
  end
end
