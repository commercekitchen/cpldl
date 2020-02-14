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
end