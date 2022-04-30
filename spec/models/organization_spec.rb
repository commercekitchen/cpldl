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
      expect(org).not_to be_valid
    end

    it 'requires a subdomain' do
      org.subdomain = nil
      expect(org).not_to be_valid
    end

    it 'requires survey link if survey is enabled' do
      org.user_survey_enabled = true
      expect(org).not_to be_valid
    end

    it 'requires url format for survey link' do
      expect(org).to validate_url_of(:user_survey_link)
    end

    it 'requires url format for spanish survey link' do
      expect(org).to validate_url_of(:spanish_survey_link)
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

  describe '#student_programs?' do
    it 'is false if organization has no school programs' do
      expect(org.student_programs?).to eq(false)
    end

    it 'is true if organization has school programs' do
      org.programs << FactoryBot.create(:program, parent_type: :students_and_parents)
      expect(org.student_programs?).to eq(true)
    end
  end

  describe '#assignable_roles' do
    it 'returns correct options for typical organization' do
      expect(org.assignable_roles).to contain_exactly('Admin', 'User', 'Trainer')
    end

    it 'returns correct options for program organization with student programs' do
      FactoryBot.create(:program, :student_program, organization: org)
      expect(org.assignable_roles).to contain_exactly('Admin', 'User', 'Trainer', 'Parent', 'Student')
    end
  end

  describe '#pla' do
    it 'returns PLA organization' do
      expect(Organization.pla).to eq(pla)
    end
  end

  describe '#training_site_link' do
    it 'returns main training site by default' do
      expect(org.training_site_link).to eq('https://training.test.org')
    end

    it 'returns subsite link if configured' do
      org.update(use_subdomain_for_training_site: true)
      expect(org.training_site_link).to eq("https://training.#{org.subdomain}.test.org")
    end
  end

  describe '#survey_url' do
    let(:survey_url) { 'https://survey.example.com' }
    let(:spanish_survey_url) { 'https://spanish.example.com' }

    before do
      org.user_survey_link = survey_url
    end

    it 'returns user_survey_link for en locale' do
      expect(org.survey_url(:en)).to eq(survey_url)
    end

    it 'returns user_survey_link for es locale if no spanish survey' do
      expect(org.survey_url(:es)).to eq(survey_url)
    end

    it 'returns user_survey_link for es locale for blank spanish survey' do
      org.spanish_survey_link = ''
      expect(org.survey_url(:es)).to eq(survey_url)
    end

    it 'returns spanish_survey_link for es locale if spanish survey exists' do
      org.spanish_survey_link = spanish_survey_url
      expect(org.survey_url(:es)).to eq(spanish_survey_url)
    end

    it 'returns user_survey_link for unknown locale' do
      expect(org.survey_url(:foobar)).to eq(survey_url)
    end
  end
end
