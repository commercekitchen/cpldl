# frozen_string_literal: true

require 'feature_helper'

feature 'Admin accepts invitation' do
  context 'library card login user' do
    let(:library_card_org) { FactoryBot.create(:organization, :library_card_login, subdomain: 'lco') }

    before do
      switch_to_subdomain(library_card_org.subdomain)

      @invited_user = AdminInvitationService.invite(email: 'test_invite@example.com', organization: library_card_org)
    end

    it 'should have an ok response' do
      token = @invited_user.raw_invitation_token
      visit "/users/invitation/accept?invitation_token=#{token}"
      expect(page).to have_content('Set your password')
    end
  end

  context 'non library card login user' do
    let(:org) { FactoryBot.create(:organization, subdomain: 'test') }

    before do
      switch_to_subdomain(org.subdomain)

      @invited_user = AdminInvitationService.invite(email: 'test_invite@example.com', organization: org)
    end

    it 'should allow user to fill in password, then profile' do
      token = @invited_user.raw_invitation_token
      visit "/users/invitation/accept?invitation_token=#{token}"
      expect(page).to have_content('Set your password')

      password = Faker::Internet.password

      fill_in 'New Password', with: password
      fill_in 'Confirm new password', with: password
      click_button 'Set my password'

      expect(current_path).to eq(profile_path)
      expect(page).to have_content('This is the first time you have logged in, please update your profile.')
      fill_in 'First Name', with: 'Test'
      click_button 'Save'

      expect(page).to have_content 'Profile was successfully updated.'
    end
  end
end
