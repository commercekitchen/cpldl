require 'rails_helper'

RSpec.describe PartnerPolicy, type: :policy do
  let(:user) { FactoryBot.create(:user) }
  let(:organization) { user.organization }
  let(:guest_user) { GuestUser.new(organization: organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let!(:partner) { FactoryBot.create(:partner, organization: organization) }
  let!(:other_org_partner) { FactoryBot.create(:partner) }

  subject { described_class }

  permissions ".scope" do
    it 'should raise error for guest user' do
      expect { Pundit.policy_scope!(guest_user, Partner) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'should raise error for user' do
      expect { Pundit.policy_scope!(user, Partner) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'should list correct partners for admin' do
      expect(Pundit.policy_scope!(admin, Partner)).to contain_exactly(partner)
    end
  end

  permissions :create? do
    it 'should not allow guest user to create' do
      expect(subject).to_not permit(guest_user, Partner.new(organization: organization))
    end

    it 'should not allow user to create' do
      expect(subject).to_not permit(user, Partner.new(organization: organization))
    end

    it 'should allow admin to create at their own org' do
      expect(subject).to permit(admin, Partner.new(organization: organization))
    end

    it 'should not allow admin to create for another org' do
      expect(subject).to_not permit(admin, Partner.new)
    end
  end

  permissions :destroy? do
    it 'should not allow guest user to destroy' do
      expect(subject).to_not permit(guest_user, partner)
    end

    it 'should not allow user to destroy' do
      expect(subject).to_not permit(user, partner)
    end

    it 'should allow admin to destroy at their own org' do
      expect(subject).to permit(admin, partner)
    end

    it 'should not allow admin to destroy for another org' do
      expect(subject).to_not permit(admin, other_org_partner)
    end
  end
end
