# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttachmentPolicy, type: :policy do
  let(:user) { FactoryBot.create(:user) }
  let(:organization) { user.organization }
  let(:guest_user) { GuestUser.new(organization: organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let(:course) { FactoryBot.create(:course, organization: organization) }
  let!(:attachment) { FactoryBot.create(:attachment, course: course) }
  let!(:other_org_attachment) { FactoryBot.create(:attachment) }

  subject { described_class }

  permissions :destroy? do
    it 'should not allow guest user to destroy' do
      expect(subject).to_not permit(guest_user, attachment)
    end

    it 'should not allow user to destroy' do
      expect(subject).to_not permit(user, attachment)
    end

    it 'should allow admin to destroy at their own org' do
      expect(subject).to permit(admin, attachment)
    end

    it 'should not allow admin to destroy for another org' do
      expect(subject).to_not permit(admin, other_org_attachment)
    end
  end
end
