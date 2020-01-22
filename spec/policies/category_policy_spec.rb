# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CategoryPolicy, type: :policy do
  let(:organization) { FactoryBot.create(:organization) }

  let!(:subsite_record) { FactoryBot.create(:category, organization: organization) }
  let!(:other_subsite_record) { FactoryBot.create(:category) }

  it_behaves_like "AdminOnly Policy"

  permissions '.scope' do
    let(:guest_user) { GuestUser.new(organization: organization) }
    let(:user) { FactoryBot.create(:user, organization: organization) }
    let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }

    it 'should raise error for guest user' do
      expect { Pundit.policy_scope!(guest_user, Category) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'should raise error for user' do
      expect { Pundit.policy_scope!(user, Category) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'should list correct categories for admin' do
      organization.reload
      expect(Pundit.policy_scope!(admin, Category)).to contain_exactly(subsite_record)
    end
  end
end
