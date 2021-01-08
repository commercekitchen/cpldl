# frozen_string_literal: true

require 'feature_helper'

feature 'Admin user invites other admins' do
  let(:org) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, :admin, organization: org) }

  before(:each) do
    switch_to_subdomain(org.subdomain)
    login_as user
  end

  scenario 'submits blank form', js: true do
    visit new_user_invitation_path
    expect(page).to have_content 'Invite Admin'

    click_button 'Send Invitation'

    expect(current_path).to eq(new_user_invitation_path)
  end

  scenario 'attempts to invite user with invalid email' do
    visit new_user_invitation_path
    expect(page).to have_content 'Invite Admin'

    fill_in 'Email', with: 'foobar notanemail'

    click_button 'Send Invitation'

    expect(page).to have_content('Email is invalid')
  end

  scenario 'invites user with valid email' do
    visit new_user_invitation_path
    expect(page).to have_content 'Invite Admin'

    fill_in 'Email', with: 'test@example.com'

    click_button 'Send Invitation'

    success_message = 'An invitation email has been sent to test@example.com.'

    expect(page).to have_content(success_message)
    expect(current_path).to eq(root_path)
  end

end
