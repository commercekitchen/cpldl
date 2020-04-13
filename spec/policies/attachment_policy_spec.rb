# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttachmentPolicy, type: :policy do
  let(:organization) { FactoryBot.create(:organization) }

  let(:course) { FactoryBot.create(:course, organization: organization) }

  let!(:subsite_record) { FactoryBot.create(:attachment, course: course) }
  let!(:other_subsite_record) { FactoryBot.create(:attachment) }

  it_behaves_like 'AdminOnly Policy', { skip_scope: true, skip_actions: [:show?] }

  permissions :show? do
    let(:pla) { FactoryBot.create(:default_organization) }
    let(:pla_user) { FactoryBot.create(:user, organization: pla) }

    let(:subsite) { FactoryBot.create(:organization) }
    let(:subsite_user) { FactoryBot.create(:user, organization: subsite) }

    let(:guest_user) { GuestUser.new(organization: subsite) }

    let(:pla_course) { FactoryBot.create(:course, organization: pla) }
    let!(:child_course) { FactoryBot.create(:course, organization: subsite, parent: pla_course) }

    let(:attachment) { FactoryBot.create(:attachment, course: pla_course) }
    let(:other_course_attachment) { FactoryBot.create(:attachment) }

    subject { described_class }

    context 'guest user' do
      it 'should be permitted' do
        expect(subject).to permit(guest_user, attachment)
      end

      it 'should not be permitted for attachment not related to subsite course' do
        expect(subject).to_not permit(guest_user, other_course_attachment)
      end

      it 'should not be permitted for private course attachment' do
        child_course.update!(access_level: 'authenticated_users')
        expect(subject).to_not permit(guest_user, attachment)
      end
    end

    context 'original course user' do
      it 'should be permitted for current organization' do
        expect(subject).to permit(pla_user, attachment)
      end

      it 'should be permitted for private course' do
        child_course.update!(access_level: 'authenticated_users')
        expect(subject).to permit(pla_user, attachment)
      end
    end

    context 'authenticated user' do
      it 'should be permitted for current organization' do
        expect(subject).to permit(subsite_user, attachment)
      end

      it 'should not be permitted for another organization' do
        expect(subject).to_not permit(subsite_user, other_course_attachment)
      end

      it 'should be permitted for private course' do
        child_course.update!(access_level: 'authenticated_users')
        expect(subject).to permit(subsite_user, attachment)
      end
    end
  end
end
