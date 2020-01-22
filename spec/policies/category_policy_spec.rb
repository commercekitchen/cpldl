require 'rails_helper'

RSpec.describe CategoryPolicy, type: :policy do
  let(:user) { FactoryBot.create(:user) }
  let(:organization) { user.organization }
  let(:guest_user) { GuestUser.new(organization: organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let!(:category) { FactoryBot.create(:category, organization: organization) }
  let!(:other_org_category) { FactoryBot.create(:category) }

  subject { described_class }

  permissions ".scope" do
    it 'should raise error for guest user' do
      expect { Pundit.policy_scope!(guest_user, Category) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'should raise error for user' do
      expect { Pundit.policy_scope!(user, Category) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'should list correct categories for admin' do
      organization.reload
      expect(Pundit.policy_scope!(admin, Category)).to contain_exactly(category)
    end
  end

  permissions :create? do
    it 'should not allow guest user to create' do
      expect(subject).to_not permit(guest_user, Category.new(organization: organization))
    end

    it 'should not allow user to create' do
      expect(subject).to_not permit(user, Category.new(organization: organization))
    end

    it 'should allow admin to create at their own org' do
      expect(subject).to permit(admin, Category.new(organization: organization))
    end

    it 'should not allow admin to create for another org' do
      expect(subject).to_not permit(admin, Category.new)
    end
  end

  permissions :update? do
    it 'should not allow guest user to create' do
      expect(subject).to_not permit(guest_user, category)
    end

    it 'should not allow user to create' do
      expect(subject).to_not permit(user, category)
    end

    it 'should allow admin to create at their own org' do
      expect(subject).to permit(admin, category)
    end

    it 'should not allow admin to create for another org' do
      expect(subject).to_not permit(admin, other_org_category)
    end
  end

  permissions :destroy? do
    it 'should not allow guest user to destroy' do
      expect(subject).to_not permit(guest_user, category)
    end

    it 'should not allow user to destroy' do
      expect(subject).to_not permit(user, category)
    end

    it 'should allow admin to destroy at their own org' do
      expect(subject).to permit(admin, category)
    end

    it 'should not allow admin to destroy for another org' do
      expect(subject).to_not permit(admin, other_org_category)
    end
  end
end
