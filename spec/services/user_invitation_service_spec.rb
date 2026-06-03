# frozen_string_literal: true

require 'rails_helper'

describe UserInvitationService do
  let(:organization) { FactoryBot.create(:organization) }
  let(:inviter) { FactoryBot.create(:user) }
  let(:email) { Faker::Internet.free_email }

  it 'creates a user with the user role by default' do
    expect do
      UserInvitationService.invite(email: email, organization: organization)
    end.to change(User.with_role(:user, organization), :count).by(1)
  end

  it 'creates a user with the admin role when specified' do
    expect do
      UserInvitationService.invite(email: email, organization: organization, role: 'admin')
    end.to change(User.with_role(:admin, organization), :count).by(1)
  end

  it 'creates a user with the trainer role when specified' do
    expect do
      UserInvitationService.invite(email: email, organization: organization, role: 'trainer')
    end.to change(User.with_role(:trainer, organization), :count).by(1)
  end

  it 'sends an invitation email' do
    expect do
      UserInvitationService.invite(email: email, organization: organization)
    end.to change(ActionMailer::Base.deliveries, :count).by(1)
  end

  it 'records the inviting user when given' do
    UserInvitationService.invite(email: email, organization: organization, inviter: inviter)
    expect(User.last.invited_by).to eq(inviter)
  end

  it 'assigns the user to the organization' do
    UserInvitationService.invite(email: email, organization: organization)
    expect(User.last.organization).to eq(organization)
  end
end
