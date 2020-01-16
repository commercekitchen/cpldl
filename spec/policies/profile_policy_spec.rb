require 'rails_helper'

describe ProfilePolicy, type: :policy do
  let(:user) { FactoryBot.create(:user) }
  let(:organization) { user.organization }
  let(:profile) { user.profile }
  let(:user2) { FactoryBot.create(:user) }
  let(:guest_user) { GuestUser.new(organization: organization) }

  subject { described_class }

  permissions :show? do
    it 'should allow user to view their profile' do
      expect(subject).to permit(user, profile)
    end

    it 'should not allow a user to view another user profile' do
      expect(subject).to_not permit(user2, profile)
    end

    it 'should not allow guest user to view a profile' do
      expect(subject).to_not permit(guest_user, profile)
    end
  end

  permissions :create? do
    pending "add some examples to (or delete) #{__FILE__}"
  end

  permissions :update? do
    it 'should allow user to update their profile' do
      expect(subject).to permit(user, profile)
    end

    it 'should not allow a user to update another user profile' do
      expect(subject).to_not permit(user2, profile)
    end

    it 'should not allow guest user to update a profile' do
      expect(subject).to_not permit(guest_user, profile)
    end
  end

  permissions :destroy? do
    pending "add some examples to (or delete) #{__FILE__}"
  end
end
