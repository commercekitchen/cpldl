# frozen_string_literal: true

require 'rails_helper'
require 'csv'

describe RegistrationExporter do
  describe 'email user' do
    describe 'no branches organization' do
      let(:organization) { FactoryBot.create(:organization, accepts_programs: true) }
      let(:program) { FactoryBot.create(:program, organization: organization) }
      let!(:user) { FactoryBot.create(:user, :with_last_name, organization: organization) }
      let!(:program_user) { FactoryBot.create(:user, :with_last_name, program: program, organization: organization) }

      let(:subject) { RegistrationExporter.new(organization) }
      let(:parsed_report) { CSV.parse(subject.to_csv, headers: true) }

      it 'should generate correct column headers' do
        expect(parsed_report.headers).to eq(['Email', 'Registration Date', 'Program Name'])
      end

      it 'should include user email' do
        expect(parsed_report.to_s).to match(user.email)
      end

      it 'should include program user program name' do
        expect(parsed_report.to_s).to match(program.program_name)
      end

      it 'should include correct registration date' do
        expect(parsed_report.to_s).to match(user.created_at.to_s)
      end
    end

    describe 'branches organization' do
      let(:organization) { FactoryBot.create(:organization, branches: true) }
      let(:branch) { FactoryBot.create(:library_location, organization: organization) }
      let(:profile) { FactoryBot.build(:profile, library_location: branch) }
      let!(:branch_user) { FactoryBot.create(:user, profile: profile, organization: organization) }

      let(:subject) { RegistrationExporter.new(organization) }
      let(:parsed_report) { CSV.parse(subject.to_csv, headers: true) }

      it 'should generate correct column headers' do
        expect(parsed_report.headers).to eq(['Email', 'Registration Date', 'Branch Name', 'Zip'])
      end

      it 'should include branch name' do
        expect(parsed_report.to_s).to match(branch.name)
      end

      it 'should match branch zipcode' do
        expect(parsed_report.to_s).to match(branch.zipcode.to_s)
      end
    end

    describe 'student program organization' do
      let(:organization) { FactoryBot.create(:organization, accepts_programs: true) }
      let(:program) { FactoryBot.create(:program, parent_type: :students_and_parents, organization: organization) }
      let(:school) { FactoryBot.create(:school, organization: organization) }
      let(:profile) { FactoryBot.build(:profile, :with_last_name) }
      let(:subject) { RegistrationExporter.new(organization) }
      let(:parsed_report) { CSV.parse(subject.to_csv, headers: true) }

      before do
        @user = FactoryBot.create(:user, profile: profile, program: program, organization: organization, school: school, student_id: '12345')
      end

      it 'should generate correct column headers' do
        expect(parsed_report.headers).to eq(['Email', 'Registration Date', 'Program Name', 'School Type', 'School Name', 'Student ID(s)'])
      end

      it 'should include program name' do
        expect(parsed_report.to_s).to match(program.program_name)
      end

      it 'should include school type' do
        expect(parsed_report.to_s).to match(school.school_type.titleize)
      end

      it 'should include school name' do
        expect(parsed_report.to_s).to match(school.school_name)
      end

      it 'should include student IDs value' do
        expect(parsed_report.to_s).to match(@user.student_id)
      end
    end
  end

  describe 'library_card user' do
    let(:library_card_organization) { FactoryBot.create(:organization, :library_card_login) }
    let(:subject) { RegistrationExporter.new(library_card_organization) }
    let(:parsed_report) { CSV.parse(subject.to_csv, headers: true) }
    let!(:library_card_user) { FactoryBot.create(:user, :library_card_login_user, organization: library_card_organization) }

    it 'should include correct column headers' do
      expect(parsed_report.headers).to eq(['Library Card Number', 'Registration Date'])
    end
  end

  describe 'phone_number user' do
    let(:organization) { FactoryBot.create(:organization, phone_number_users_enabled: true) }
    let!(:user) { FactoryBot.create(:phone_number_user, phone_number: '1231231234', organization: organization) }

    let(:exporter) { described_class.new(organization) }
    let(:report) { CSV.parse(exporter.to_csv, headers: true) }

    it 'should have correct headers' do
      expect(report.headers).to eq(['Phone Number', 'Registration Date'])
    end

    it 'should include user phone number' do
      expect(report.to_s).to match('1231231234')
    end
  end

  describe 'deidentified report' do
    let(:organization) { FactoryBot.create(:organization, phone_number_users_enabled: true, deidentify_reports: true) }
    let!(:user) { FactoryBot.create(:phone_number_user, phone_number: '1231231234', organization: organization) }

    let(:exporter) { described_class.new(organization) }
    let(:report) { CSV.parse(exporter.to_csv, headers: true) }

    it 'contains correct headers' do
      expect(report.headers).to eq(['Uuid', 'Registration Date'])
    end

    it 'should include user uuid' do
      expect(report.to_s).to match(user.uuid)
    end
  end

  describe 'date ranges' do
    let(:organization) { FactoryBot.create(:organization) }
    let!(:user) { FactoryBot.create(:user, organization: organization) }
    let(:out_of_range_user) { FactoryBot.create(:user, organization: organization) }

    let(:subject) { RegistrationExporter.new(organization, start_date: 1.month.ago, end_date: Time.zone.now) }
    let(:parsed_report) { CSV.parse(subject.to_csv, headers: true) }

    before { out_of_range_user.update_columns(created_at: 2.years.ago) }

    it 'should include user email' do
      expect(parsed_report.to_s).to match(user.email)
    end

    it 'should not include out of range user' do
      expect(parsed_report.to_s).not_to match(out_of_range_user.email)
    end
  end
end
