# frozen_string_literal: true

require 'rails_helper'
require 'csv'

describe Exporters::NoCoursesReportExporter do
  describe 'email login organization report' do
    let(:organization) { FactoryBot.create(:organization) }
    let!(:user) { FactoryBot.create(:user, organization: organization) }
    let!(:parent_user) { FactoryBot.create(:user, :parent, organization: organization) }
    let!(:student_user) { FactoryBot.create(:user, :student, organization: organization) }
    let!(:admin_user) { FactoryBot.create(:user, :admin, organization: organization) }
    let!(:trainer_user) { FactoryBot.create(:user, :trainer, organization: organization) }

    let(:exporter) { described_class.new(organization) }
    let(:report) { CSV.parse(exporter.stream_csv.to_a.join, headers: true) }

    it 'should contain correct headers' do
      expect(report.headers).to eq(['Email', 'Registration Date'])
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

    it 'should not include users with course progresses' do
      FactoryBot.create(:course_progress, user: user)
      expect(report.to_s).to_not match(user.email)
    end

    it 'should use time range if specified' do
      old_user = create(:user, organization: organization)
      old_user.update_columns(created_at: 2.months.ago)
      exporter = described_class.new(organization, start_date: 1.month.ago, end_date: Time.zone.now)
      report = CSV.parse(exporter.stream_csv.to_a.join, headers: true)
      expect(report.to_s).not_to match(old_user.email)
    end
  end

  describe 'library_card_login organization report' do
    let(:library_card_organization) { FactoryBot.create(:organization, :library_card_login) }
    let!(:library_card_user) { FactoryBot.create(:user, :library_card_login_user, organization: library_card_organization) }

    let(:exporter) { described_class.new(library_card_organization) }
    let(:report) { CSV.parse(exporter.stream_csv.to_a.join, headers: true) }

    it 'should have correct headers' do
      expect(report.headers).to eq(['Library Card Number', 'Registration Date'])
    end

    it 'should include user library card number' do
      expect(report.to_s).to match(library_card_user.library_card_number)
    end
  end

  describe 'phone number login organization report' do
    let(:organization) { FactoryBot.create(:organization, phone_number_users_enabled: true) }
    let!(:user) { FactoryBot.create(:phone_number_user, phone_number: '1231231234', organization: organization) }

    let(:exporter) { described_class.new(organization) }
    let(:report) { CSV.parse(exporter.stream_csv.to_a.join, headers: true) }

    it 'should have correct headers' do
      expect(report.headers).to eq(['Phone Number', 'Registration Date'])
    end

    it 'should include user phone number' do
      expect(report.to_s).to match('1231231234')
    end
  end
end
