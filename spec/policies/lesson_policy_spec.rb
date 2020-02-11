# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LessonPolicy, type: :policy do
  let(:user) { FactoryBot.create(:user) }
  let(:organization) { user.organization }
  let(:main_site) { FactoryBot.create(:default_organization) }
  let(:guest_user) { GuestUser.new(organization: organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let(:no_auth_organization) { FactoryBot.create(:organization, :no_login_required) }
  let(:no_auth_guest_user) { GuestUser.new(organization: no_auth_organization) }

  let(:everyone_course) { FactoryBot.create(:course, organization: organization) }
  let(:authorized_user_course) { FactoryBot.create(:course, organization: organization, access_level: :authenticated_users) }
  let(:other_subsite_course) { FactoryBot.create(:course) }
  let(:draft_course) { FactoryBot.create(:draft_course, organization: organization) }
  let(:archived_course) { FactoryBot.create(:archived_course, organization: organization) }
  let(:no_auth_course) { FactoryBot.create(:course, organization: no_auth_organization) }
  let(:no_auth_private_course) { FactoryBot.create(:course, organization: no_auth_organization, access_level: :authenticated_users) }

  let(:everyone_lesson) { FactoryBot.create(:lesson, course: everyone_course) }
  let(:authorized_user_lesson) { FactoryBot.create(:lesson, course: authorized_user_course) }
  let(:other_subsite_lesson) { FactoryBot.create(:lesson, course: other_subsite_course) }
  let(:draft_course_lesson) { FactoryBot.create(:lesson, course: draft_course) }
  let(:archived_course_lesson) { FactoryBot.create(:lesson, course: archived_course) }
  let(:no_auth_lesson) { FactoryBot.create(:lesson, course: no_auth_course) }
  let(:no_auth_private_lesson) { FactoryBot.create(:lesson, course: no_auth_private_course) }

  subject { described_class }

  permissions :show? do
    context 'guest user' do
      it 'denies access if lesson course is only for authorized users' do
        expect(subject).to_not permit(guest_user, authorized_user_lesson)
      end

      it 'denies access if lesson course is public but auth is required' do
        expect(subject).to_not permit(guest_user, everyone_lesson)
      end

      it 'allows access if subsite allows no auth access' do
        expect(subject).to permit(no_auth_guest_user, no_auth_lesson)
      end

      it 'does not allow access if subsite allows no auth access, but course is only for authenticated users' do
        expect(subject).to_not permit(no_auth_guest_user, no_auth_private_lesson)
      end

      it 'denies access for lesson courses from another subsite' do
        expect(subject).to_not permit(guest_user, other_subsite_lesson)
      end

      it 'denies access for lesson of draft course' do
        expect(subject).to_not permit(guest_user, draft_course_lesson)
      end

      it 'denies access for lesson of archived course' do
        expect(subject).to_not permit(guest_user, archived_course_lesson)
      end
    end

    context 'authenticated user' do
      it 'allows access if lesson course is only for authorized users' do
        expect(subject).to permit(user, authorized_user_lesson)
      end

      it 'allows access if lesson course is public' do
        expect(subject).to permit(user, everyone_lesson)
      end

      it 'denies access for lesson courses from another subsite' do
        expect(subject).to_not permit(user, other_subsite_lesson)
      end

      it 'denies access for lesson of draft course' do
        expect(subject).to_not permit(user, draft_course_lesson)
      end

      it 'denies access for lesson of archived course' do
        expect(subject).to_not permit(user, archived_course_lesson)
      end
    end
  end

  permissions :create? do
    context 'guest user' do
      it 'should not be permitted' do
        expect(subject).to_not permit(guest_user, Lesson.new(course: everyone_course))
      end
    end

    context 'subsite user' do
      it 'should not be permitted' do
        expect(subject).to_not permit(user, Lesson.new(course: everyone_course))
      end
    end

    context 'subsite admin' do
      it 'should be permitted' do
        expect(subject).to permit(admin, Lesson.new(course: everyone_course))
      end
    end
  end

  permissions :update? do
    context 'guest user' do
      it 'should not be permitted' do
        expect(subject).to_not permit(guest_user, everyone_lesson)
      end
    end

    context 'subsite user' do
      it 'should not be permitted' do
        expect(subject).to_not permit(user, everyone_lesson)
      end
    end

    context 'subsite admin' do
      it 'should be permitted' do
        expect(subject).to permit(admin, everyone_lesson)
      end
    end
  end
end
