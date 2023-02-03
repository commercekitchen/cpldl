# frozen_string_literal: true

require 'rails_helper'

describe ProfilePolicy, type: :policy do
  let(:user) { FactoryBot.create(:user) }
  let(:organization) { user.organization }
  let(:profile) { user.profile }
  let(:user2) { FactoryBot.create(:user) }
  let(:guest_user) { GuestUser.new(organization: organization) }
  let(:phone_number_user) { FactoryBot.create(:phone_number_user) }

  subject { described_class }

  permissions :show? do
    it 'should allow user to view their profile' do
      expect(subject).to permit(user, profile)
    end

    it 'should not allow a user to view another user profile' do
      expect(subject).not_to permit(user2, profile)
    end

    it 'should not allow guest user to view a profile' do
      expect(subject).not_to permit(guest_user, profile)
    end

    it 'should not allow phone number user to view their profile' do
      pnu_profile = FactoryBot.build(:profile, user: phone_number_user)
      expect(subject).not_to permit(phone_number_user, pnu_profile)
    end
  end

  permissions :update? do
    it 'should allow user to update their profile' do
      expect(subject).to permit(user, profile)
    end

    it 'should not allow a user to update another user profile' do
      expect(subject).not_to permit(user2, profile)
    end

    it 'should not allow guest user to update a profile' do
      expect(subject).not_to permit(guest_user, profile)
    end

    it 'should not allow phone number user to view their profile' do
      pnu_profile = FactoryBot.build(:profile, user: phone_number_user)
      expect(subject).not_to permit(phone_number_user, pnu_profile)
    end
  end
end
