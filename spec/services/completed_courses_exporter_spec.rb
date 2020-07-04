# frozen_string_literal: true

require 'rails_helper'
require 'csv'

describe CompletedCoursesExporter do
  describe 'email login organization report' do
    let(:organization) { FactoryBot.create(:organization) }
    let(:program) { FactoryBot.create(:program, organization: organization) }
    let(:branch) { FactoryBot.create(:library_location, organization: organization) }
    let(:profile) { FactoryBot.build(:profile, library_location: branch) }

    let(:user) { FactoryBot.create(:user, organization: organization, profile: profile) }
    let!(:user_course_progress) { FactoryBot.create(:course_progress, user: user, completed_at: Time.zone.now) }

    let(:parent_user) { FactoryBot.create(:user, :parent, organization: organization) }
    let!(:parent_user_course_progress) { FactoryBot.create(:course_progress, user: parent_user, completed_at: Time.zone.now) }

    let(:student_user) { FactoryBot.create(:user, :student, organization: organization) }
    let!(:student_user_course_progress) { FactoryBot.create(:course_progress, user: student_user, completed_at: Time.zone.now) }

    let(:admin_user) { FactoryBot.create(:user, :admin, organization: organization) }
    let!(:admin_user_course_progress) { FactoryBot.create(:course_progress, user: admin_user, completed_at: Time.zone.now) }

    let(:trainer_user) { FactoryBot.create(:user, :trainer, organization: organization) }
    let!(:trainer_user_course_progress) { FactoryBot.create(:course_progress, user: trainer_user, completed_at: Time.zone.now) }

    let(:user_with_program) { FactoryBot.create(:user, program: program, organization: organization) }
    let!(:user_with_program_course_progress) { FactoryBot.create(:course_progress, user: user_with_program, completed_at: Time.zone.now) }

    let(:exporter) { described_class.new(organization) }
    let(:report) { CSV.parse(exporter.to_csv, headers: true) }

    it 'should contain correct headers' do
      expect(report.headers).to eq(['Email', 'Program Name', 'Course', 'Course Completed At', 'Branch'])
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
      let(:user_with_school) { FactoryBot.create(:user, program: school_program, school: school, organization: organization) }

      before do
        FactoryBot.create(:course_progress, user: user_with_school, completed_at: Time.zone.now)
      end

      it 'should include school headers' do
        expect(report.headers).to eq(['Email', 'Program Name', 'Course', 'Course Completed At', 'Branch', 'School Type', 'School Name'])
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
    let(:report) { CSV.parse(exporter.to_csv, headers: true) }

    it 'should have correct headers' do
      expect(report.headers).to eq(['Library Card Number', 'Program Name', 'Course', 'Course Completed At', 'Branch'])
    end

    it 'should include user library card number' do
      expect(report.to_s).to match(library_card_user.library_card_number)
    end
  end
end
