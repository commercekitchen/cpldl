# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SchoolPolicy, type: :policy do
  let(:user) { FactoryBot.create(:user) }
  let(:organization) { user.organization }
  let(:guest_user) { GuestUser.new(organization: organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let!(:school) { FactoryBot.create(:school, organization: organization) }
  let!(:other_org_school) { FactoryBot.create(:school) }

  subject { described_class }

  permissions '.scope' do
    it 'should raise error for guest user' do
      expect { Pundit.policy_scope!(guest_user, School) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'should raise error for user' do
      expect { Pundit.policy_scope!(user, School) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'should list correct schools for admin' do
      expect(Pundit.policy_scope!(admin, School)).to contain_exactly(school)
    end
  end

  permissions :create? do
    it 'should not allow guest user to create' do
      expect(subject).to_not permit(guest_user, School.new(organization: organization))
    end

    it 'should not allow user to create' do
      expect(subject).to_not permit(user, School.new(organization: organization))
    end

    it 'should allow admin to create at their own org' do
      expect(subject).to permit(admin, School.new(organization: organization))
    end

    it 'should not allow admin to create for another org' do
      expect(subject).to_not permit(admin, School.new)
    end
  end

  permissions :destroy? do
    it 'should not allow guest user to destroy' do
      expect(subject).to_not permit(guest_user, school)
    end

    it 'should not allow user to destroy' do
      expect(subject).to_not permit(user, school)
    end

    it 'should allow admin to destroy at their own org' do
      expect(subject).to permit(admin, school)
    end

    it 'should not allow admin to destroy for another org' do
      expect(subject).to_not permit(admin, other_org_school)
    end
  end
end
