# frozen_string_literal: true

require 'rails_helper'

describe CoursePolicy, type: :policy do
  let(:organization) { FactoryBot.create(:organization) }

  let!(:subsite_record) { FactoryBot.create(:course, organization: organization) }
  let!(:other_subsite_record) { FactoryBot.create(:course) }

  let!(:authorized_user_course) { FactoryBot.create(:course, organization: organization, access_level: :authenticated_users) }
  let!(:draft_course) { FactoryBot.create(:draft_course, organization: organization) }
  let!(:archived_course) { FactoryBot.create(:archived_course, organization: organization) }

  subject { described_class }

  it_behaves_like 'AdminOnly Policy', { skip_actions: [:show?], skip_scope: true }

  describe 'Scope' do
    let(:guest_user) { GuestUser.new(organization: organization) }
    let(:user) { FactoryBot.create(:user, organization: organization) }
    let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }

    context 'guest user' do
      let(:scope) { Pundit.policy_scope!(guest_user, Course) }

      it 'should only display public courses' do
        expect(scope).to contain_exactly(subsite_record)
      end
    end

    context 'subsite user' do
      let(:scope) { Pundit.policy_scope!(user, Course) }

      it 'should display public and authorized-user-only courses' do
        expect(scope).to contain_exactly(subsite_record, authorized_user_course)
      end
    end

    context 'subsite admin' do
      let(:scope) { Pundit.policy_scope!(admin, Course) }

      it 'should display all courses' do
        expect(scope).to contain_exactly(subsite_record, authorized_user_course, draft_course)
      end
    end
  end

  permissions :preview? do
    let(:pla) { FactoryBot.create(:default_organization) }
    let(:guest_user) { GuestUser.new(organization: organization) }
    let(:user) { FactoryBot.create(:user, organization: organization) }
    let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
    let(:course) { FactoryBot.create(:course, organization: pla) }
    let(:subsite_course) { FactoryBot.create(:course) }

    context 'guest_user' do
      it 'denies access' do
        expect(subject).to_not permit(guest_user, course)
      end
    end

    context 'subsite user' do
      it 'denies access' do
        expect(subject).to_not permit(user, course)
      end
    end

    context 'subsite admin' do
      it 'allows access to pla course' do
        expect(subject).to permit(admin, course)
      end

      it 'denies access to non PLA courses' do
        expect(subject).to_not permit(admin, subsite_course)
      end
    end
  end

  permissions :show? do
    let(:guest_user) { GuestUser.new(organization: organization) }
    let(:user) { FactoryBot.create(:user, organization: organization) }
    let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }

    context 'guest user' do
      it 'denies access if course is only for authorized users' do
        expect(subject).to_not permit(guest_user, authorized_user_course)
      end

      it 'allows access if course is public' do
        expect(subject).to permit(guest_user, subsite_record)
      end

      it 'denies access for courses from another subsite' do
        expect(subject).to_not permit(guest_user, other_subsite_record)
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
        expect(subject).to permit(user, subsite_record)
      end

      it 'allows access if course is only for authorized users' do
        expect(subject).to permit(user, authorized_user_course)
      end

      it 'denies access for courses from another subsite' do
        expect(subject).to_not permit(user, other_subsite_record)
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
    let(:guest_user) { GuestUser.new(organization: organization) }
    let(:user) { FactoryBot.create(:user, organization: organization) }
    let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }

    context 'guest user' do
      it 'denies access if course is only for authorized users' do
        expect(subject).to_not permit(guest_user, authorized_user_course)
      end

      it 'denies access even if course is public' do
        expect(subject).to_not permit(guest_user, subsite_record)
      end

      it 'denies access for courses from another subsite' do
        expect(subject).to_not permit(guest_user, other_subsite_record)
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
        expect(subject).to permit(user, subsite_record)
      end

      it 'allows tracking if course is only for authorized users' do
        expect(subject).to permit(user, authorized_user_course)
      end

      it 'denies tracking for courses from another subsite' do
        expect(subject).to_not permit(user, other_subsite_record)
      end

      it 'denies tracking for draft courses' do
        expect(subject).to_not permit(user, draft_course)
      end

      it 'denies tracking for archived courses' do
        expect(subject).to_not permit(user, archived_course)
      end
    end
  end

  describe 'permitted_attributes' do
    let(:pla) { FactoryBot.create(:default_organization) }
    let(:pla_course) { FactoryBot.create(:course, organization: pla) }
    let(:admin) { FactoryBot.create(:user, :admin) }
    let(:subsite) { admin.organization }
    let(:guest_user) { GuestUser.new(organization: subsite) }
    let(:user) { FactoryBot.create(:user, organization: subsite) }
    let(:imported_subsite_course) { FactoryBot.create(:course, organization: subsite, parent: pla_course) }
    let(:custom_subsite_course) { FactoryBot.create(:course, organization: subsite) }

    context 'for a guest user' do
      subject { CoursePolicy.new(guest_user, custom_subsite_course) }

      it 'should be empty' do
        expect(subject.permitted_attributes).to eq([])
      end
    end

    context 'for a subsite user' do
      subject { CoursePolicy.new(user, custom_subsite_course) }

      it 'should be empty' do
        expect(subject.permitted_attributes).to eq([])
      end
    end

    context 'for a subsite admin editing an imported course' do
      subject { CoursePolicy.new(admin, imported_subsite_course) }

      it 'should contain appropriate attributes' do
        expect(subject.permitted_attributes).to contain_exactly(:category_id,
                                                                :access_level,
                                                                :pub_status,
                                                                :notes,
                                                                category_attributes: %i[name organization_id],
                                                                attachments_attributes: %i[document title doc_type file_description _destroy])
      end
    end

    context 'for a subsite admin creating or editing a custom course' do
      subject { CoursePolicy.new(admin, custom_subsite_course) }

      it 'should contain appropriate attributes' do
        expect(subject.permitted_attributes).to contain_exactly(:title,
                                                                :seo_page_title,
                                                                :meta_desc,
                                                                :summary,
                                                                :description,
                                                                :contributor,
                                                                :pub_status,
                                                                :language_id,
                                                                :level,
                                                                :notes,
                                                                :delete_document,
                                                                :course_order,
                                                                :pub_date,
                                                                :format,
                                                                :access_level,
                                                                :category_id,
                                                                topic_ids: [],
                                                                course_topics_attributes: [topic_attributes: [:title]],
                                                                category_attributes: %i[name organization_id],
                                                                attachments_attributes: %i[document title doc_type file_description _destroy])
      end
    end
  end
end
