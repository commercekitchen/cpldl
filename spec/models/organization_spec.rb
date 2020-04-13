# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Organization, type: :model do
  let(:org) { FactoryBot.create(:organization) }
  let!(:pla) { FactoryBot.create(:default_organization) }
  let!(:admin1) { FactoryBot.create(:user, :admin, organization: org) }
  let!(:admin2) { FactoryBot.create(:user, :admin, organization: org) }
  let!(:user1) { FactoryBot.create(:user, organization: org) }
  let!(:user2) { FactoryBot.create(:user) }

  it { should have_many(:cms_pages) }
  it { should have_many(:library_locations) }

  describe 'scopes' do
    let(:parent_course) { FactoryBot.create(:course_with_lessons) }

    describe 'using_lesson' do
      let(:parent_lesson) { parent_course.lessons.first }
      let(:subsite_course) { FactoryBot.create(:course, organization: org) }
      let!(:lesson) { FactoryBot.create(:lesson, parent_id: parent_lesson.id, course: subsite_course) }

      it 'includes only orgs using the passed lesson' do
        expect(Organization.using_lesson(parent_lesson.id)).to eq([org])
      end
    end

    describe 'using_course' do
      let!(:course) { FactoryBot.create(:course, parent_id: parent_course.id, organization: org) }

      it 'includes only orgs using the passed course' do
        expect(Organization.using_course(parent_course.id)).to eq([org])
      end
    end
  end

  describe 'validations' do
    it 'requires a name' do
      org.name = nil
      expect(org).to_not be_valid
    end

    it 'requires a subdomain' do
      org.subdomain = nil
      expect(org).to_not be_valid
    end
  end

  describe '#users_count' do
    it 'returns the count of its users' do
      expect(org.user_count).to eq(3)
    end
  end

  describe '#admin_user_emails' do
    it 'returns emails of the admins' do
      expect(org.admin_user_emails).to include(admin1.email)
      expect(org.admin_user_emails).to include(admin2.email)
      expect(org.admin_user_emails).not_to include(user1.email)
      expect(org.admin_user_emails).not_to include(user2.email)
    end
  end

  describe '#pla' do
    it 'returns PLA organization' do
      expect(Organization.pla).to eq(pla)
    end
  end
end
