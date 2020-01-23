# frozen_string_literal: true

require 'rails_helper'

describe UserPolicy, type: :policy do
  let(:organization) { FactoryBot.create(:organization) }
  let(:user2) { FactoryBot.create(:user) }
  let(:other_subsite_user) { FactoryBot.create(:user) }
  let(:trainer) { FactoryBot.create(:user, :trainer, organization: organization) }

  subject { described_class }

  let!(:subsite_record) { user }
  let!(:other_subsite_record) { other_subsite_user }

  it_behaves_like 'AdminOnly Policy', { skip_scope: true, skip_actions: %i[show? update?] }

  describe 'Scope' do
    let(:guest_user) { GuestUser.new(organization: organization) }
    let(:user) { FactoryBot.create(:user, organization: organization) }
    let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }

    context 'guest user' do
      let(:scope) { Pundit.policy_scope!(guest_user, User) }

      it 'should raise an authorization error' do
        expect { scope }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context 'subsite user' do
      let(:scope) { Pundit.policy_scope!(user, User) }

      it 'should raise an authorization error' do
        expect { scope }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context 'subsite admin' do
      let(:scope) { Pundit.policy_scope!(admin, User) }

      it 'should display all subsite users' do
        expect(scope).to contain_exactly(user, admin, trainer)
      end
    end

    context 'subsite trainer' do
      let(:scope) { Pundit.policy_scope!(trainer, User) }

      it 'should display all subsite users' do
        expect(scope).to contain_exactly(user, admin, trainer)
      end
    end
  end

  permissions :show? do
    let(:guest_user) { GuestUser.new(organization: organization) }
    let(:user) { FactoryBot.create(:user, organization: organization) }
    let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }

    it 'should allow user to view their account' do
      expect(subject).to permit(user, user)
    end

    it 'should not allow a user to view another user account' do
      expect(subject).to_not permit(user2, user)
    end

    it 'should not allow guest user to view an account' do
      expect(subject).to_not permit(guest_user, user)
    end

    it 'should allow admin to view an account' do
      expect(subject).to permit(admin, user)
    end
  end

  permissions :update? do
    let(:guest_user) { GuestUser.new(organization: organization) }
    let(:user) { FactoryBot.create(:user, organization: organization) }
    let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }

    it 'should allow user to update their account' do
      expect(subject).to permit(user, user)
    end

    it 'should not allow a user to update another user account' do
      expect(subject).to_not permit(user2, user)
    end

    it 'should not allow guest user to update an account' do
      expect(subject).to_not permit(guest_user, user)
    end

    it 'should allow an admin to update a user in their subsite' do
      expect(subject).to permit(admin, user)
    end
  end

  permissions :confirm? do
    let(:guest_user) { GuestUser.new(organization: organization) }
    let(:user) { FactoryBot.create(:user, organization: organization) }
    let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }

    it 'should not allow user to manually confirm their account' do
      expect(subject).to_not permit(user, user)
    end

    it 'should not allow a user to confirm another user account' do
      expect(subject).to_not permit(user2, user)
    end

    it 'should not allow guest user to confirm an account' do
      expect(subject).to_not permit(guest_user, user)
    end

    it 'should allow an admin to confirm a user in their subsite' do
      expect(subject).to permit(admin, user)
    end

    it 'should not allow an admin to confirm a user in another subsite' do
      expect(subject).to_not permit(admin, other_subsite_user)
    end

    it 'should allow a trainer to confirm a user in their subsite' do
      expect(subject).to permit(trainer, user)
    end

    it 'should not allow a trainer to confirm a user in another subsite' do
      expect(subject).to_not permit(trainer, other_subsite_user)
    end
  end
end
