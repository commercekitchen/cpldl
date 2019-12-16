# frozen_string_literal: true

require 'rails_helper'
require 'csv'

describe UnfinishedCoursesExporter do
  describe 'email login organization report' do
    let(:organization) { FactoryBot.create(:organization) }
    let(:program) { FactoryBot.create(:program, organization: organization) }

    let(:user) { FactoryBot.create(:user, organization: organization) }
    let!(:user_course_progress) { FactoryBot.create(:course_progress, user: user) }

    let(:parent_user) { FactoryBot.create(:user, :parent, organization: organization) }
    let!(:parent_user_course_progress) { FactoryBot.create(:course_progress, user: parent_user) }

    let(:student_user) { FactoryBot.create(:user, :student, organization: organization) }
    let!(:student_user_course_progress) { FactoryBot.create(:course_progress, user: student_user) }

    let(:admin_user) { FactoryBot.create(:user, :admin, organization: organization) }
    let!(:admin_user_course_progress) { FactoryBot.create(:course_progress, user: admin_user) }

    let(:trainer_user) { FactoryBot.create(:user, :trainer, organization: organization) }
    let!(:trainer_user_course_progress) { FactoryBot.create(:course_progress, user: trainer_user) }

    let(:user_with_program) { FactoryBot.create(:user, program: program, organization: organization) }
    let!(:user_with_program_course_progress) { FactoryBot.create(:course_progress, user: user_with_program) }

    let(:exporter) { described_class.new(organization) }
    let(:report) { CSV.parse(exporter.to_csv, headers: true) }

    it 'should contain correct headers' do
      expect(report.headers).to eq(['Email', 'Program Name', 'Course', 'Course Started At'])
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

    it 'should contain course started date' do
      expect(report.to_s).to match(user_course_progress.created_at.strftime('%m-%d-%Y'))
    end

    it 'should not include course completions' do
      user_course_progress.update(completed_at: Time.zone.now)
      expect(report.to_s).to_not match(user.email)
    end
  end

  describe 'library_card_login organization report' do
    let(:library_card_organization) { FactoryBot.create(:organization, :library_card_login) }
    let(:library_card_user) { FactoryBot.create(:user, :library_card_login_user, organization: library_card_organization) }
    let!(:completion) { FactoryBot.create(:course_progress, user: library_card_user) }

    let(:exporter) { described_class.new(library_card_organization) }
    let(:report) { CSV.parse(exporter.to_csv, headers: true) }

    it 'should have correct headers' do
      expect(report.headers).to eq(['Library Card Number', 'Program Name', 'Course', 'Course Started At'])
    end

    it 'should include user library card number' do
      expect(report.to_s).to match(library_card_user.library_card_number)
    end
  end
end
