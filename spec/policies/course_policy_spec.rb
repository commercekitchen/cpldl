# frozen_string_literal: true

require 'rails_helper'

describe CoursePolicy, type: :policy do
  let(:user) { FactoryBot.create(:user) }
  let(:organization) { user.organization }
  let(:main_site) { FactoryBot.create(:default_organization) }
  let(:guest_user) { GuestUser.new(organization: organization) }
  let(:admin_user) { FactoryBot.create(:user, :admin, organization: organization) }

  let!(:everyone_course) { FactoryBot.create(:course, organization: organization) }
  let!(:authorized_user_course) { FactoryBot.create(:course, organization: organization, access_level: :authenticated_users) }
  let!(:other_subsite_course) { FactoryBot.create(:course) }
  let!(:draft_course) { FactoryBot.create(:draft_course, organization: organization) }
  let!(:archived_course) { FactoryBot.create(:archived_course, organization: organization) }

  subject { described_class }

  describe 'Scope' do
    context 'guest user' do
      let(:scope) { Pundit.policy_scope!(guest_user, Course) }

      it 'should only display public courses' do
        expect(scope).to contain_exactly(everyone_course)
      end
    end

    context 'subsite user' do
      let(:scope) { Pundit.policy_scope!(user, Course) }

      it 'should display public and authorized-user-only courses' do
        expect(scope).to contain_exactly(everyone_course, authorized_user_course)
      end
    end

    context 'subsite admin' do
      let(:scope) { Pundit.policy_scope!(admin_user, Course) }

      it 'should display all courses' do
        expect(scope).to contain_exactly(everyone_course, authorized_user_course, draft_course)
      end
    end
  end

  permissions :show? do
    context 'guest user' do
      it 'denies access if course is only for authorized users' do
        expect(subject).to_not permit(guest_user, authorized_user_course)
      end

      it 'allows access if course is public' do
        expect(subject).to permit(guest_user, everyone_course)
      end

      it 'denies access for courses from another subsite' do
        expect(subject).to_not permit(guest_user, other_subsite_course)
      end

      it 'denies access for draft courses' do
        expect(subject).to_not permit(guest_user, draft_course)
      end

      it 'denies access for archived courses' do
        expect(subject).to_not permit(guest_user, archived_course)
      end
    end

    context 'authenticated user' do
      it 'allows access if course is public' do
        expect(subject).to permit(user, everyone_course)
      end

      it 'allows access if course is only for authorized users' do
        expect(subject).to permit(user, authorized_user_course)
      end

      it 'denies access for courses from another subsite' do
        expect(subject).to_not permit(user, other_subsite_course)
      end

      it 'denies access for draft courses' do
        expect(subject).to_not permit(user, draft_course)
      end

      it 'denies access for archived courses' do
        expect(subject).to_not permit(user, archived_course)
      end
    end
  end

  permissions :track? do
    context 'guest user' do
      it 'denies access if course is only for authorized users' do
        expect(subject).to_not permit(guest_user, authorized_user_course)
      end

      it 'denies access even if course is public' do
        expect(subject).to_not permit(guest_user, everyone_course)
      end

      it 'denies access for courses from another subsite' do
        expect(subject).to_not permit(guest_user, other_subsite_course)
      end

      it 'denies access for draft courses' do
        expect(subject).to_not permit(guest_user, draft_course)
      end

      it 'denies access for archived courses' do
        expect(subject).to_not permit(guest_user, archived_course)
      end
    end

    context 'authenticated user' do
      it 'allows tracking if course is public' do
        expect(subject).to permit(user, everyone_course)
      end

      it 'allows tracking if course is only for authorized users' do
        expect(subject).to permit(user, authorized_user_course)
      end

      it 'denies tracking for courses from another subsite' do
        expect(subject).to_not permit(user, other_subsite_course)
      end

      it 'denies tracking for draft courses' do
        expect(subject).to_not permit(user, draft_course)
      end

      it 'denies tracking for archived courses' do
        expect(subject).to_not permit(user, archived_course)
      end
    end
  end

  permissions :create? do
    it 'does not allow guest user to create' do
      expect(subject).to_not permit(guest_user, Course.new(organization: organization))
    end

    it 'does not allow authenticated user to create' do
      expect(subject).to_not permit(user, Course.new(organization: organization))
    end

    it 'does allow subsite admin to create' do
      expect(subject).to permit(admin_user, Course.new(organization: organization))
    end
  end

  permissions :update? do
    it 'does not allow guest user to update' do
      expect(subject).to_not permit(guest_user, everyone_course)
    end

    it 'does not allow authenticated user to update' do
      expect(subject).to_not permit(user, everyone_course)
    end

    it 'does allow subsite admin to update' do
      expect(subject).to permit(admin_user, everyone_course)
    end
  end

  permissions :destroy? do
    it 'does not allow guest user to destroy' do
      expect(subject).to_not permit(guest_user, everyone_course)
    end

    it 'does not allow authenticated user to destroy' do
      expect(subject).to_not permit(user, everyone_course)
    end

    it 'does allow subsite admin to destroy' do
      expect(subject).to permit(admin_user, everyone_course)
    end
  end
end
