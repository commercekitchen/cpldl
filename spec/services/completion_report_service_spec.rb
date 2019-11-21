require 'rails_helper'
require 'csv'

describe CompletionReportService do
  let(:organization) { FactoryBot.create(:organization) }
  let(:library1) { FactoryBot.create(:library_location, organization: organization) }
  let(:library2) { FactoryBot.create(:library_location, organization: organization) }

  let(:other_zip) { '12345' }

  let(:partner1) { FactoryBot.create(:partner, organization: organization) }
  let(:partner2) { FactoryBot.create(:partner, organization: organization) }

  let(:responses1) { { 'set_one' => '1', 'set_two' => '3', 'set_three' => '3' } }
  let(:responses2) { { 'set_one' => '2', 'set_two' => '1', 'set_three' => '2' } }

  let(:user) do
    FactoryBot.create(:user, organization: organization, quiz_responses_object: responses1, partner: partner1,
                      profile_attributes: { library_location: library1 })
  end

  let(:user2) do
    FactoryBot.create(:user, organization: organization, quiz_responses_object: responses2, partner: partner2,
                      profile_attributes: { library_location: library1 })
  end

  let(:user3) do
    FactoryBot.create(:user, organization: organization, partner: partner1,
                      profile_attributes: { zip_code: other_zip, library_location: library2 })
  end

  let(:course1) { FactoryBot.create(:course, organization: organization) }
  let(:course2) { FactoryBot.create(:course, organization: organization) }

  let!(:course_progress1) do
    FactoryBot.create(:course_progress, course_id: course1.id, tracked: true, completed_at: Time.zone.now, user: user)
  end

  let!(:course_progress2) do
    FactoryBot.create(:course_progress, course_id: course2.id, tracked: true, completed_at: Time.zone.now, user: user)
  end

  let!(:course_progress3) do
    FactoryBot.create(:course_progress, course_id: course1.id, tracked: true, completed_at: Time.zone.now, user: user2)
  end

  let!(:course_progress4) do
    FactoryBot.create(:course_progress, course_id: course2.id, tracked: true, completed_at: Time.zone.now, user: user3)
  end

  let(:report_service) { CompletionReportService.new(organization: organization) }

  describe 'course completions by zip code' do
    let(:report) { report_service.generate_completion_report(group_by: 'zip_code') }
    let(:parsed_report) { CSV.parse(report, headers: true) }

    it 'should generate correct column headers' do
      expect(parsed_report.headers).to eq(["Zip Code", "Sign-Ups(total)", "Course Title", "Completions"])
    end

    it 'should include correct count for zip code 1' do
      expect(parsed_report.to_s).to match("#{user.profile.zip_code},2")
    end

    it 'should include correct count for other zip code' do
      expect(parsed_report.to_s).to match("#{other_zip},1")
    end

    it 'should include completions count for course 1' do
      expect(parsed_report.to_s).to match("#{course1.title},2")
    end

    it 'should include completions count for course 2' do
      expect(parsed_report.to_s).to match("#{course2.title},1")
    end
  end

  describe 'course completions by partner' do
    let(:report) { report_service.generate_completion_report(group_by: 'partner') }
    let(:parsed_report) { CSV.parse(report, headers: true) }

    it 'should generate correct column headers' do
      expect(parsed_report.headers).to eq(["Partner", "Sign-Ups(total)", "Course Title", "Completions"])
    end

    it 'should include correct count for partner 1' do
      expect(parsed_report.to_s).to match("#{partner1.name},2")
    end

    it 'should include correct count for partner 2' do
      expect(parsed_report.to_s).to match("#{partner2.name},1")
    end

    it 'should include completions count for course 1' do
      expect(parsed_report.to_s).to match("#{course1.title},1")
    end

    it 'should include completions count for course 2' do
      expect(parsed_report.to_s).to match("#{course2.title},2")
    end
  end

  describe 'return completions by library' do
    let(:report) { report_service.generate_completion_report(group_by: 'library') }
    let(:parsed_report) { CSV.parse(report, headers: true) }

    it 'should generate correct column headers' do
      expect(parsed_report.headers).to eq(["Library", "Sign-Ups(total)", "Course Title", "Completions"])
    end

    it 'should include correct count for library 1' do
      expect(parsed_report.to_s).to match("#{library1.name},2")
    end

    it 'should include correct count for library 2' do
      expect(parsed_report.to_s).to match("#{library2.name},1")
    end

    it 'should include completions count for course 1' do
      expect(parsed_report.to_s).to match("#{course1.title},2")
    end

    it 'should include completions count for course 2' do
      expect(parsed_report.to_s).to match("#{course2.title},1")
    end
  end

  describe 'completions by quiz response' do
    let(:report) { report_service.generate_completion_report(group_by: 'survey_responses') }
    let(:parsed_report) { CSV.parse(report, headers: true) }

    it 'should return correct column headers' do
      expected_headers = ['How comfortable are you with desktop or laptop computers?',
                          'How comfortable are you using a phone, tablet, or iPad to access the Internet?',
                          'What would you like to do with a computer?',
                          'Total Responses',
                          'Course Title',
                          'Completions']
      expect(parsed_report.headers).to eq(expected_headers)
    end

    it 'should return correct responses count for response set 1' do
      expect(parsed_report.to_s).to match("#{I18n.t('quiz.set_one_1')},\"#{I18n.t('quiz.set_two_3')}\",#{I18n.t('quiz.set_three_3')},1")
    end

    it 'should return correct responses count for response set 2' do
      expect(parsed_report.to_s).to match("\"#{I18n.t('quiz.set_one_2')}\",\"#{I18n.t('quiz.set_two_1')}\",#{I18n.t('quiz.set_three_2')},1")
    end

    it 'should include completions count for course 1' do
      expect(parsed_report.to_s).to match("#{course1.title},1")
    end

    it 'should include completions count for course 2' do
      expect(parsed_report.to_s).to match("#{course2.title},1")
    end
  end
end
