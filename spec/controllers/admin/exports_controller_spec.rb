# frozen_string_literal: true

require 'rails_helper'

describe Admin::ExportsController do
  before(:each) do
    @organization = create(:organization)
    @request.host = 'chipublib.test.host'
    @admin = create(:user, :admin, organization: @organization)
    sign_in @admin
    @zip_csv = { format: 'csv', version: 'zip' }
  end

  describe '#completions' do
    it 'respond to csv' do
      get :completions, params: @zip_csv
      expect(response.body).to_not be(nil)
      expect(response.body).to eq("Zip Code,Sign-Ups(total),Course Title,Completions\n")
    end
  end

  describe '#data_for_completions_report_by' do
    before(:each) do
      @user = create(:user, quiz_responses_object: { 'set_one' => '1', 'set_two' => '3', 'set_three' => '3' })
      @user.add_role(:user, @organization)

      @user2 = create(:user, quiz_responses_object: { 'set_one' => '2', 'set_three' => '2' })
      @user2.add_role(:user, @organization)

      @user3 = create(:user)
      @user3.add_role(:user, @organization)

      @language = create(:language)
      @course1 = create(:course, title: 'Course 1',
                                             language: @language,
                                             description: 'Mocha Java Scripta',
                                             organization: @organization)
      @course2 = create(:course, title: 'Course 2',
                                             language: @language,
                                             organization: @organization)
      @course_progress1 = create(:course_progress, course_id: @course1.id, tracked: true, completed_at: Time.zone.now)
      @course_progress2 = create(:course_progress, course_id: @course2.id, tracked: true, completed_at: Time.zone.now)
      @course_progress3 = create(:course_progress, course_id: @course1.id, tracked: true, completed_at: Time.zone.now)
      @course_progress4 = create(:course_progress, course_id: @course2.id, tracked: true, completed_at: Time.zone.now)
      @user.course_progresses << [@course_progress1, @course_progress2]
      @user2.course_progresses << [@course_progress3]
      @user3.course_progresses << [@course_progress4]
    end

    it 'return completions by zip' do
      returned = controller.data_for_completions_report_by_zip
      expect(returned).to eq({ version: 'zip', '90210' => { sign_ups: 3, completions: { 'Course 2' => 2, 'Course 1' => 2 } } })
    end

    it 'return completions by lib' do
      returned = controller.data_for_completions_report_by_lib
      expect(returned).to eq({ version: 'lib', nil => { sign_ups: 3, completions: { 'Course 2' => 2, 'Course 1' => 2 } } })
    end

    it 'return completions by quiz response' do
      returned = controller.data_for_completions_report_by_survey_responses
      expect(returned).to eq(
        {
          version: 'survey_responses',
          { 'set_one' => '1', 'set_two' => '3', 'set_three' => '3' } => { responses: 1, completions: { 'Course 1' => 1, 'Course 2' => 1 } },
          { 'set_one' => '2', 'set_three' => '2' } => { responses: 1, completions: { 'Course 1' => 1 } }
        }
      )
    end
  end
end
