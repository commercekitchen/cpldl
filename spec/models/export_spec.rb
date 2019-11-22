# frozen_string_literal: true

require 'rails_helper'

describe Export do
  let(:library) { create(:library_location) }
  let(:lib_data) { { :version => 'library', library.id => { sign_ups: 1, completions: { 'Sample Course 3' => 1 } } } }
  let(:survey_responses_data) do
    { :version => 'survey_responses',
      { 'set_one' => '3', 'set_two' => '3', 'set_three' => '5' } => { responses: 3, completions: { 'Test Course' => 3 } },
      { 'set_three' => '8' } => { responses: 2, completions: { 'Intro to BS' => 2 } } }
  end

  context 'check library name lookup' do
    let(:csv) { Export.to_csv_for_completion_report(lib_data) }
    it 'looks up the library name' do
      expect(csv).to match(library.name)
    end
  end

  context 'survey_responses export' do
    let(:csv) { Export.to_csv_for_completion_report(survey_responses_data) }

    it 'translates question_1 response correctly' do
      expect(csv).to match(/I can use a computer, but I'd like to learn more./)
    end

    it 'translates question_2 response correctly' do
      expect(csv).to match(/I can use at least one of these technologies, but I'd like to learn more./)
    end

    it 'translates question_3 response correctly' do
      expect(csv).to match(/Communicate with friends and family through email and video./)
    end

    it 'translates lone question_8 correctly' do
      expect(csv).to match(/Search for information./)
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
