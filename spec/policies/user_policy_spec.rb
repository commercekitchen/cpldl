# frozen_string_literal: true

require 'rails_helper'

describe UserPolicy, type: :policy do
  let(:user) { FactoryBot.create(:user) }
  let(:organization) { user.organization }
  let(:profile) { user.profile }
  let(:user2) { FactoryBot.create(:user) }
  let(:guest_user) { GuestUser.new(organization: organization) }

  subject { described_class }

  permissions :show? do
    it 'should allow user to view their account' do
      expect(subject).to permit(user, user)
    end

    it 'should not allow a user to view another user account' do
      expect(subject).to_not permit(user2, user)
    end

    it 'should not allow guest user to view an account' do
      expect(subject).to_not permit(guest_user, user)
    end
  end

  permissions :update? do
    it 'should allow user to update their account' do
      expect(subject).to permit(user, user)
    end

    it 'should not allow a user to update another user account' do
      expect(subject).to_not permit(user2, user)
    end

    it 'should not allow guest user to update an account' do
      expect(subject).to_not permit(guest_user, user)
    end
  end
end
