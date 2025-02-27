# frozen_string_literal: true

require 'rails_helper'
require 'csv'

describe CompletedCoursesExporter do
  describe 'email login organization report' do
    let(:organization) { FactoryBot.create(:organization, accepts_programs: true, branches: true) }
    let(:program) { FactoryBot.create(:program, organization: organization) }
    let(:inactive_program) { FactoryBot.create(:program, organization: organization, active: false) }
    let(:branch) { FactoryBot.create(:library_location, organization: organization) }
    let(:profile) { FactoryBot.build(:profile, :with_last_name, library_location: branch) }

    let(:user) { FactoryBot.create(:user, organization: organization, profile: profile) }
    let!(:user_course_progress) { FactoryBot.create(:course_progress, user: user, completed_at: Time.zone.now) }

    let(:parent_user) { FactoryBot.create(:user, :parent, organization: organization, profile: profile) }
    let!(:parent_user_course_progress) { FactoryBot.create(:course_progress, user: parent_user, completed_at: Time.zone.now) }

    let(:student_user) { FactoryBot.create(:user, :student, organization: organization, profile: profile) }
    let!(:student_user_course_progress) { FactoryBot.create(:course_progress, user: student_user, completed_at: Time.zone.now) }

    let(:admin_user) { FactoryBot.create(:user, :admin, organization: organization, profile: profile) }
    let!(:admin_user_course_progress) { FactoryBot.create(:course_progress, user: admin_user, completed_at: Time.zone.now) }

    let(:trainer_user) { FactoryBot.create(:user, :trainer, organization: organization, profile: profile) }
    let!(:trainer_user_course_progress) { FactoryBot.create(:course_progress, user: trainer_user, completed_at: Time.zone.now) }

    let(:user_with_program) { FactoryBot.create(:user, program: program, organization: organization, profile: profile) }
    let!(:user_with_program_course_progress) { FactoryBot.create(:course_progress, user: user_with_program, completed_at: Time.zone.now) }

    let(:user_with_inactive_program) { FactoryBot.create(:user, program: inactive_program, organization: organization, profile: profile) }
    let!(:user_with_inactive_program_course_progress) { FactoryBot.create(:course_progress, user: user_with_inactive_program, completed_at: Time.zone.now) }

    let(:exporter) { described_class.new(organization) }
    let(:report) { CSV.parse(exporter.stream_csv.to_a.join, headers: true) }

    it 'should contain correct headers' do
      expect(report.headers).to eq(['Email', 'Course', 'Course Completed At', 'Program Name', 'Branch'])
    end

    it 'should contain user email' do
      expect(report.to_s).to match(user.email)
    end

    it 'should contain students' do
      expect(report.to_s).to match(student_user.email)
    end

    it 'should contain parents' do
      expect(report.to_s).to match(parent_user.email)
    end

    it 'should not contain admins' do
      expect(report.to_s).to_not match(admin_user.email)
    end

    it 'should not contain trainers' do
      expect(report.to_s).to_not match(trainer_user.email)
    end

    it 'should include program information' do
      expect(report.to_s).to match(program.program_name)
    end

    it 'should include program information for inactive programs' do
      expect(report.to_s).to match(inactive_program.program_name)
    end

    it 'should contain course name' do
      expect(report.to_s).to match(user_course_progress.course.title)
    end

    it 'should contain completion date' do
      expect(report.to_s).to match(user_course_progress.completed_at.strftime('%m-%d-%Y'))
    end

    it 'should contain branch name' do
      expect(report.to_s).to match(branch.name)
    end

    context 'with school program' do
      let(:school_program) { FactoryBot.create(:program, parent_type: :students_and_parents, organization: organization) }
      let(:school) { FactoryBot.create(:school, organization: organization) }
      let(:user_with_school) { FactoryBot.create(:user, program: school_program, school: school, organization: organization, profile: profile) }

      before do
        FactoryBot.create(:course_progress, user: user_with_school, completed_at: Time.zone.now)
      end

      it 'should include school headers' do
        expect(report.headers).to eq(['Email', 'Course', 'Course Completed At', 'Program Name', 'Branch', 'School Type', 'School Name'])
      end

      it 'should contain school type' do
        expect(report.to_s).to match(school.school_type.titleize)
      end

      it 'should contain school name' do
        expect(report.to_s).to match(school.school_name)
      end
    end
  end

  describe 'library_card_login organization report' do
    let(:library_card_organization) { FactoryBot.create(:organization, :library_card_login) }
    let(:library_card_user) { FactoryBot.create(:user, :library_card_login_user, organization: library_card_organization) }
    let!(:completion) { FactoryBot.create(:course_progress, user: library_card_user, completed_at: Time.zone.now) }

    let(:exporter) { described_class.new(library_card_organization) }
    let(:report) { CSV.parse(exporter.stream_csv.to_a.join, headers: true) }

    it 'should have correct headers' do
      expect(report.headers).to eq(['Library Card Number', 'Course', 'Course Completed At'])
    end

    it 'should include user library card number' do
      expect(report.to_s).to match(library_card_user.library_card_number)
    end
  end

  describe 'phone number login organization report' do
    let(:organization) { FactoryBot.create(:organization, phone_number_users_enabled: true) }
    let(:user) { FactoryBot.create(:phone_number_user, phone_number: '1231231234', organization: organization) }
    let!(:completion) { FactoryBot.create(:course_progress, user: user, completed_at: Time.zone.now) }

    let(:exporter) { described_class.new(organization) }
    let(:report) { CSV.parse(exporter.stream_csv.to_a.join, headers: true) }

    it 'should have correct headers' do
      expect(report.headers).to eq(['Phone Number', 'Course', 'Course Completed At'])
    end

    it 'should include user phone number' do
      expect(report.to_s).to match('1231231234')
    end
  end

  describe 'date range' do
    let(:organization) { FactoryBot.create(:organization) }

    let(:user) { FactoryBot.create(:user, organization: organization) }
    let!(:user_course_progress) { FactoryBot.create(:course_progress, user: user, completed_at: Time.zone.now) }

    let(:out_of_range_user) { FactoryBot.create(:user, organization: organization) }
    let!(:out_of_range_course_progress) { FactoryBot.create(:course_progress, user: user, completed_at: 2.years.ago) }

    let(:exporter) { described_class.new(organization, start_date: 1.month.ago, end_date: Time.zone.now) }
    let(:report) { CSV.parse(exporter.stream_csv.to_a.join, headers: true) }

    it 'should contain recent completion user email' do
      expect(report.to_s).to match(user.email)
    end

    it 'should not contain older completion user email' do
      expect(report.to_s).not_to match(out_of_range_user.email)
    end
  end
end
