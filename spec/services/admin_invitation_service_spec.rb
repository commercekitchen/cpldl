# frozen_string_literal: true

require 'rails_helper'

describe AdminInvitationService do
  let(:organization) { FactoryBot.create(:organization) }
  let(:email) { Faker::Internet.free_email }
  let(:user) { FactoryBot.create(:user) }

  it 'should create an admin user' do
    expect do
      AdminInvitationService.invite(email: email, organization: organization)
    end.to change(User.with_role(:admin, organization), :count).by(1)
  end

  it 'should send an invitation' do
    expect do
      AdminInvitationService.invite(email: email, organization: organization)
    end.to change(ActionMailer::Base.deliveries, :count).by(1)
  end

  it 'should add inviting user if given' do
    AdminInvitationService.invite(email: email, organization: organization, inviter: user)
    expect(User.last.invited_by).to eq(user)
  end
end
