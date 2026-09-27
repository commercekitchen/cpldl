# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Lessons', type: :request do
  describe 'GET /api/v1/lessons' do
    let(:organization) { create(:organization) }
    let(:course) { create(:course, organization: organization) }

    before do
      host! "#{organization.subdomain}.test.host"
      create_list(:lesson, 2, course: course)
    end

    it 'returns no lessons by default' do
      get '/api/v1/lessons'

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      lesson_payloads = body.fetch('lessons')

      expect(lesson_payloads).to be_empty
    end

    it 'filters lessons by course_id when provided' do
      other_course = create(:course, organization: organization)
      create_list(:lesson, 2, course: other_course)

      get '/api/v1/lessons', params: { course_id: course.id }

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      lesson_payloads = body.fetch('lessons')

      expect(lesson_payloads).to all(satisfy { |lesson| lesson['course']['summary'] == course.summary })
      expect(lesson_payloads.size).to eq(2)
    end

    it 'only includes lessons from published courses' do
      unpublished_course = create(:course, organization: organization, pub_status: 'D')
      create_list(:lesson, 2, course: unpublished_course)

      get '/api/v1/lessons', params: { course_id: unpublished_course.id }

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      lesson_payloads = body.fetch('lessons')

      expect(lesson_payloads).to be_empty
    end
  end

  describe 'POST /api/v1/lessons/complete' do
    let(:organization) { create(:organization) }
    let(:course) { create(:course, organization: organization) }
    let(:user) { create(:user, organization: organization) }
    let(:same_origin_headers) { { 'Origin' => "http://#{organization.subdomain}.test.host" } }

    before do
      host! "#{organization.subdomain}.test.host"
    end

    it 'marks a lesson complete and returns course_completed false while other lessons remain' do
      first_lesson = create(:lesson, course: course, lesson_order: 1)
      create(:lesson, course: course, lesson_order: 2)
      allow_any_instance_of(Api::V1::LessonsController).to receive(:current_user).and_return(user)

      post '/api/v1/lessons/complete',
           params: { course_id: course.to_param, lesson_id: first_lesson.to_param },
           headers: same_origin_headers

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      progress = user.course_progresses.find_by(course_id: course.id)

      expect(progress.completed_lessons).to include(first_lesson)
      expect(body['course_completed']).to eq(false)
      expect(body['redirect_path']).to eq(course_lesson_lesson_complete_path(course, first_lesson, preview: nil))
    end

    it 'marks the course complete and returns course_completed true once every lesson is done' do
      first_lesson = create(:lesson, course: course, lesson_order: 1)
      second_lesson = create(:lesson, course: course, lesson_order: 2)
      allow_any_instance_of(Api::V1::LessonsController).to receive(:current_user).and_return(user)
      progress = create(:course_progress, user: user, course: course)
      create(:lesson_completion, course_progress: progress, lesson: first_lesson)

      post '/api/v1/lessons/complete',
           params: { course_id: course.to_param, lesson_id: second_lesson.to_param },
           headers: same_origin_headers

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(progress.reload.complete?).to be(true)
      expect(body['course_completed']).to eq(true)
      expect(body['redirect_path']).to eq(course_completion_path(course))
    end

    it 'does not mark the course complete just because the assessment lesson was completed' do
      create(:lesson, course: course, lesson_order: 1)
      assessment = create(:lesson, course: course, lesson_order: 2, is_assessment: true)
      allow_any_instance_of(Api::V1::LessonsController).to receive(:current_user).and_return(user)

      post '/api/v1/lessons/complete',
           params: { course_id: course.to_param, lesson_id: assessment.to_param },
           headers: same_origin_headers

      body = JSON.parse(response.body)
      progress = user.course_progresses.find_by(course_id: course.id)

      expect(progress.complete?).to be(false)
      expect(body['course_completed']).to eq(false)
      expect(body['redirect_path']).to eq(course_lesson_lesson_complete_path(course, assessment, preview: nil))
    end

    it 'supports guest completion and returns course_completed false while lessons remain' do
      first_lesson = create(:lesson, course: course, lesson_order: 1)
      create(:lesson, course: course, lesson_order: 2)
      organization.update(login_required: false)
      allow_any_instance_of(Api::V1::LessonsController).to receive(:current_user).and_return(nil)

      post '/api/v1/lessons/complete',
           params: { course_id: course.to_param, lesson_id: first_lesson.to_param },
           headers: same_origin_headers

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body['course_completed']).to eq(false)
    end

    it 'supports guest completion and returns course_completed true once every lesson is done in session' do
      first_lesson = create(:lesson, course: course, lesson_order: 1)
      second_lesson = create(:lesson, course: course, lesson_order: 2)
      organization.update(login_required: false)
      allow_any_instance_of(Api::V1::LessonsController).to receive(:current_user).and_return(nil)

      post '/api/v1/lessons/complete',
           params: { course_id: course.to_param, lesson_id: first_lesson.to_param },
           headers: same_origin_headers
      post '/api/v1/lessons/complete',
           params: { course_id: course.to_param, lesson_id: second_lesson.to_param },
           headers: same_origin_headers

      body = JSON.parse(response.body)
      expect(body['course_completed']).to eq(true)
    end
  end
end
