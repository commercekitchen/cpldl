# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CmsPagePolicy, type: :policy do
  let(:organization) { FactoryBot.create(:organization) }

  let!(:subsite_record) { FactoryBot.create(:cms_page, organization: organization) }
  let!(:other_subsite_record) { FactoryBot.create(:cms_page) }

  subject { described_class }

  it_behaves_like 'AdminOnly Policy', { model: CmsPage, skip_actions: [:show?] }

  permissions :show? do
    let(:guest_user) { GuestUser.new(organization: organization) }
    let(:user) { FactoryBot.create(:user, organization: organization) }
    let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }

    context 'guest user' do
      it 'should be permitted for current organization' do
        expect(subject).to permit(guest_user, subsite_record)
      end

      it 'should not be permitted for another organization' do
        expect(subject).to_not permit(guest_user, other_subsite_record)
      end
    end

    context 'authenticated user' do
      it 'should be permitted for current organization' do
        expect(subject).to permit(user, subsite_record)
      end

      it 'should not be permitted for another organization' do
        expect(subject).to_not permit(user, other_subsite_record)
      end
    end

    context 'admin' do
      it 'should be permitted for current organization' do
        expect(subject).to permit(admin, subsite_record)
      end

      it 'should not be permitted for another organization' do
        expect(subject).to_not permit(admin, other_subsite_record)
      end
    end
  end
end
