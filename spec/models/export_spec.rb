# frozen_string_literal: true

require 'rails_helper'

describe Export do
  let(:library) { create(:library_location) }
  let(:lib_data) { { :version => 'library', library.id => { sign_ups: 1, completions: { 'Sample Course 3' => 1 } } } }

  context 'check library name lookup' do
    let(:csv) { Export.to_csv_for_completion_report(lib_data) }
    it 'looks up the library name' do
      expect(csv).to match(library.name)
    end
  end

  context 'survey_responses export' do
    let(:comms_topic) { create(:topic, title: 'Communication & Social Media', translation_key: 'communication_social_media') }
    let(:information_searching_topic) { create(:topic, title: 'Information Searching', translation_key: 'information_searching') }

    context 'default survey' do
      let(:survey_responses_data) do
        { :version => 'survey_responses',
          { 'desktop_level' => 'Intermediate', 'mobile_level' => 'Advanced', 'topic' => comms_topic.id.to_s } => { responses: 3, completions: { 'Test Course' => 3 } },
          { 'topic' => information_searching_topic.id.to_s } => { responses: 2, completions: { 'Intro to Internet Search' => 2 } } }
      end
      let(:csv) { Export.to_csv_for_completion_report(survey_responses_data) }

      it 'translates desktop_level response correctly' do
        expect(csv).to match(/I can use a keyboard and mouse, but I'm not comfortable beyond that./)
      end

      it 'translates mobile_level response correctly' do
        expect(csv).to match(/I can use at least one of these technologies, but I'd like to learn more./)
      end

      it 'translates communication social media topic responses correctly' do
        expect(csv).to match(/Communicate with friends and family through email and video./)
      end

      it 'translates information searching topic correctly' do
        expect(csv).to match(/Search for information./)
      end
    end

    context 'custom org survey' do
      let(:org) { create(:organization, subdomain: 'getconnected', custom_recommendation_survey: true) }
      let(:online_classes_topic) { create(:topic, title: 'Take Classes Online', translation_key: 'online_classes', organization: org) }
      let(:survey_responses_data) do
        { :version => 'survey_responses',
          { 'desktop_level' => 'Intermediate', 'mobile_level' => 'Advanced', 'topic' => comms_topic.id.to_s } => { responses: 3, completions: { 'Test Course' => 3 } },
          { 'topic' => online_classes_topic.id.to_s } => { responses: 2, completions: { 'Taking Classes Online' => 2 } } }
      end
      let(:csv) { Export.to_csv_for_completion_report(survey_responses_data, org) }

      it 'translates desktop_level response correctly' do
        expect(csv).to match(/I can use a computer a little bit./)
      end

      it 'translates mobile_level response correctly' do
        expect(csv).to match(/Yes, I know how to use a smartphone./)
      end

      it 'translates communication social media topic responses correctly' do
        expect(csv).to match(/Talk to my family and friends online./)
      end

      it 'translates information searching topic correctly' do
        expect(csv).to match(/Take a class or training./)
      end
    end
  end

  context 'partners export' do
    let(:partner_data) do
      {
        version: 'partner',
        'Partner 1' => { sign_ups: 3, completions: { 'Some Course' => 2 } },
        'Partner 2' => { sign_ups: 2, completions: { 'Another Course' => 4 } }
      }
    end
    let(:csv) { Export.to_csv_for_completion_report(partner_data) }

    it 'should match partner names' do
      ['Partner 1', 'Partner 2'].each do |partner_name|
        expect(csv).to match(partner_name)
      end
    end

    it 'shoud match course names' do
      ['Some Course', 'Another Course'].each do |course_title|
        expect(csv).to match(course_title)
      end
    end
  end
end
