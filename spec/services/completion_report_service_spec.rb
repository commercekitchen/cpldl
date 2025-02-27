# frozen_string_literal: true

require 'rails_helper'
require 'csv'

describe CompletionReportService do
  let(:organization) { FactoryBot.create(:organization) }
  let(:library1) { FactoryBot.create(:library_location, organization: organization) }
  let(:library2) { FactoryBot.create(:library_location, organization: organization) }

  let(:other_zip) { '12345' }

  let(:partner1) { FactoryBot.create(:partner, organization: organization) }
  let(:partner2) { FactoryBot.create(:partner, organization: organization) }

  let(:job_search_topic) { FactoryBot.create(:topic, translation_key: 'job_search') }
  let(:sercurity_topic) { FactoryBot.create(:topic, title: 'Security', translation_key: 'security') }
  let(:responses1) { { 'desktop_level' => 'Beginner', 'mobile_level' => 'Intermediate', 'topic' => job_search_topic.id.to_s } }
  let(:responses2) { { 'desktop_level' => 'Intermediate', 'mobile_level' => 'Beginner', 'topic' => sercurity_topic.id.to_s } }

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

  let(:admin) do
    FactoryBot.create(:user, :admin, organization: organization)
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

  let!(:admin_course_progress) do
    FactoryBot.create(:course_progress, course_id: course1.id, tracked: true, completed_at: Time.zone.now, user: admin)
  end

  let(:report_service) { CompletionReportService.new(organization: organization) }

  describe 'course completions by zip code' do
    let(:report) { report_service.generate_completion_report(group_by: 'zip_code') }
    let(:parsed_report) { CSV.parse(report, headers: true) }

    it 'should generate correct column headers' do
      expect(parsed_report.headers).to eq(['Zip Code', 'Sign-Ups(total)', 'Course Title', 'Completions'])
    end

    it 'includes correct count for zip code 1' do
      expect(parsed_report.to_s).to match("#{user.profile.zip_code},2")
    end

    it 'includes correct count for other zip code' do
      expect(parsed_report.to_s).to match("#{other_zip},1")
    end

    it 'includes completions count for course 1' do
      expect(parsed_report.to_s).to match("#{course1.title},2")
    end

    it 'includes completions count for course 2' do
      expect(parsed_report.to_s).to match("#{course2.title},1")
    end

    context 'time ranges' do
      it 'only includes completions within range' do
        user2.update_columns(created_at: 2.years.ago)
        course_progress2.update_columns(completed_at: 2.years.ago)
        time_range_report = report_service.generate_completion_report(group_by: 'zip_code', start_date: 1.month.ago, end_date: Time.zone.now)
        time_range_csv = CSV.parse(time_range_report, headers: true)

        expect(time_range_csv.to_s).to match("#{user.profile.zip_code},1")
        expect(time_range_csv.to_s).to match("#{course1.title},1")
        expect(time_range_csv.to_s).to match("#{course2.title},1")
      end
    end
  end

  describe 'course completions by partner' do
    let(:report) { report_service.generate_completion_report(group_by: 'partner') }
    let(:parsed_report) { CSV.parse(report, headers: true) }

    it 'should generate correct column headers' do
      expect(parsed_report.headers).to eq(['Partner', 'Sign-Ups(total)', 'Course Title', 'Completions'])
    end

    it 'should not include no partner option from admin completion' do
      expect(parsed_report.to_s).to_not match('No Partner Selected')
    end

    it 'includes correct count for partner 1' do
      expect(parsed_report.to_s).to match("#{partner1.name},2")
    end

    it 'includes correct count for partner 2' do
      expect(parsed_report.to_s).to match("#{partner2.name},1")
    end

    it 'includes completions count for course 1' do
      expect(parsed_report.to_s).to match("#{course1.title},1")
    end

    it 'includes completions count for course 2' do
      expect(parsed_report.to_s).to match("#{course2.title},2")
    end

    context 'time ranges' do
      it 'only includes completions within range' do
        course_progress2.update_columns(completed_at: 2.years.ago)
        user3.update_columns(created_at: 2.years.ago)

        time_range_report = report_service.generate_completion_report(group_by: 'partner', start_date: 1.month.ago, end_date: Time.zone.now)
        time_range_csv = CSV.parse(time_range_report, headers: true)

        expect(time_range_csv.to_s).to match("#{partner1.name},1")
        expect(time_range_csv.to_s).to match("#{course1.title},1")
        expect(time_range_csv.to_s).to match("#{course2.title},1")
      end
    end
  end

  describe 'return completions by library' do
    let(:report) { report_service.generate_completion_report(group_by: 'library') }
    let(:parsed_report) { CSV.parse(report, headers: true) }

    it 'should generate correct column headers' do
      expect(parsed_report.headers).to eq(['Library', 'Sign-Ups(total)', 'Course Title', 'Completions'])
    end

    it 'includes correct count for library 1' do
      expect(parsed_report.to_s).to match("#{library1.name},2")
    end

    it 'includes correct count for library 2' do
      expect(parsed_report.to_s).to match("#{library2.name},1")
    end

    it 'includes completions count for course 1' do
      expect(parsed_report.to_s).to match("#{course1.title},2")
    end

    it 'includes completions count for course 2' do
      expect(parsed_report.to_s).to match("#{course2.title},1")
    end

    context 'time ranges' do
      it 'only includes completions within range' do
        course_progress2.update_columns(completed_at: 2.years.ago)
        user2.update_columns(created_at: 2.years.ago)
        time_range_report = report_service.generate_completion_report(group_by: 'library', start_date: 1.month.ago, end_date: Time.zone.now)
        time_range_csv = CSV.parse(time_range_report, headers: true)

        expect(time_range_csv.to_s).to match("#{library1.name},1")
        expect(time_range_csv.to_s).to match("#{course1.title},1")
        expect(time_range_csv.to_s).to match("#{course2.title},1")
      end
    end
  end

  describe 'completions by quiz response' do
    context 'default organization' do
      let(:report) { report_service.generate_completion_report(group_by: 'survey_responses') }
      let(:parsed_report) { CSV.parse(report, headers: true) }
      let(:translation_prefix) { 'course_recommendation_survey.default' }

      it 'returns correct column headers' do
        expected_headers = ['How comfortable are you with desktop or laptop computers? Select one.',
                            'How comfortable are you using a phone, tablet, or iPad to access the Internet? Select one.',
                            'What would you like to do with a computer? Choose your top goal.',
                            'Total Responses',
                            'Course Title',
                            'Completions']
        expect(parsed_report.headers).to eq(expected_headers)
      end

      it 'returns correct responses count for response set 1' do
        expected_responses = [I18n.t("#{translation_prefix}.desktop.beginner"),
                              "\"#{I18n.t("#{translation_prefix}.mobile.intermediate")}\"",
                              I18n.t("#{translation_prefix}.topics.job_search"),
                              1]
        expect(parsed_report.to_s).to match(expected_responses.join(','))
      end

      it 'returns correct responses count for response set 2' do
        expected_responses = ["\"#{I18n.t("#{translation_prefix}.desktop.intermediate")}\"",
                              "\"#{I18n.t("#{translation_prefix}.mobile.beginner")}\"",
                              I18n.t("#{translation_prefix}.topics.security"),
                              1]
        expect(parsed_report.to_s).to match(expected_responses.join(','))
      end

      it 'includes completions count for course 1' do
        expect(parsed_report.to_s).to match("#{course1.title},1")
      end

      it 'includes completions count for course 2' do
        expect(parsed_report.to_s).to match("#{course2.title},1")
      end

      context 'time ranges' do
        it 'only includes completions within range' do
          course_progress2.update_columns(completed_at: 2.years.ago)
          user2.update_columns(created_at: 2.years.ago)
          time_range_report = report_service.generate_completion_report(group_by: 'survey_responses', start_date: 1.month.ago, end_date: Time.zone.now)
          time_range_csv = CSV.parse(time_range_report, headers: true)
  
          expect(time_range_csv.to_s).to match("#{course1.title},1")
          expect(time_range_csv.to_s).not_to match(course2.title)

          # Don't match user2's responses
          expect(time_range_csv.to_s).not_to match(I18n.t("#{translation_prefix}.desktop.intermediate"))
        end
      end
    end

    context 'phone_number_users_enabled organization with custom survey' do
      let(:custom_org) do
        FactoryBot.create(:organization, subdomain: 'getconnected', phone_number_users_enabled: true, custom_recommendation_survey: true)
      end
      let(:org_topic) { FactoryBot.create(:topic, title: 'Online Shopping', translation_key: 'online_shopping') }
      let(:custom_responses) { { 'desktop_level' => 'Beginner', 'mobile_level' => 'Intermediate', 'topic' => org_topic.id.to_s } }
      let(:phone_user) do
        FactoryBot.create(:phone_number_user, organization: custom_org, quiz_responses_object: custom_responses)
      end
      let!(:course_progress1) do
        FactoryBot.create(:course_progress, course_id: course1.id, tracked: true, completed_at: Time.zone.now, user: phone_user)
      end
      let(:phone_report_service) { CompletionReportService.new(organization: custom_org) }
      let(:report) { phone_report_service.generate_completion_report(group_by: 'survey_responses') }
      let(:parsed_report) { CSV.parse(report, headers: true) }
      let(:translation_prefix) { 'course_recommendation_survey.getconnected' }

      it 'returns correct column headers' do
        expected_headers = ['Can you use a computer to access the Internet? Please choose one option.',
                            'Can you use a smartphone to access the Internet?',
                            'What do you want to do with a computer or smartphone? Please choose one option.',
                            'Total Responses',
                            'Course Title',
                            'Completions']
        expect(parsed_report.headers).to eq(expected_headers)
      end

      it 'returns correct responses count for response set 1' do
        expected_responses = ["\"#{I18n.t("#{translation_prefix}.desktop.beginner")}\"",
                              "#{I18n.t("#{translation_prefix}.mobile.intermediate")}",
                              "#{I18n.t("#{translation_prefix}.topics.online_shopping")}",
                              1]
        expect(parsed_report.to_s).to match(expected_responses.join(','))
      end

      it 'includes completions count for course 1' do
        expect(parsed_report.to_s).to match("#{course1.title},1")
      end

      it 'exports correctly with no topic selected' do
        phone_user.update(quiz_responses_object: custom_responses.merge('topic' => '0'))
        expect(parsed_report.to_s).to match(I18n.t("#{translation_prefix}.topics.none"))
      end

      context 'time ranges' do
        it 'only includes completions within range' do
          course_progress1.update_columns(completed_at: 2.years.ago)

          time_range_report = phone_report_service.generate_completion_report(group_by: 'survey_responses', start_date: 1.month.ago, end_date: Time.zone.now)
          time_range_csv = CSV.parse(time_range_report, headers: true)
          expect(time_range_csv.to_s).not_to match(course1.title)
        end

        it 'only includes completions within range' do
          phone_user.update_columns(created_at: 2.years.ago)

          time_range_report = phone_report_service.generate_completion_report(group_by: 'survey_responses', start_date: 1.month.ago, end_date: Time.zone.now)
          time_range_csv = CSV.parse(time_range_report, headers: true)
          expect(time_range_csv.to_s).not_to match(course1.title)
        end
      end
    end
  end
end
