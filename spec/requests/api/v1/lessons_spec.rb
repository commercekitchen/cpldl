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

    it 'returns lessons with the presenter payload' do
      get '/api/v1/lessons'

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      lessons = Lesson.last(2)
      lesson_payloads = body.fetch('lessons')

      expect(lesson_payloads.size).to eq(2)
      expect(lesson_payloads.map { |lesson| lesson['title'] }).to match_array(lessons.map(&:title))

      first_payload = lesson_payloads.first
      first_lesson = Lesson.friendly.find(first_payload['id'])

      expect(first_payload).to include(
        'title' => first_lesson.title,
        'summary' => first_lesson.summary,
        'duration' => first_lesson.duration,
        'lessonOrder' => first_lesson.lesson_order,
        'completed' => false,
        'topics' => []
      )
      expect(first_payload['course']).to include(
        'summary' => course.summary,
        'description' => course.description,
        'contributor' => course.contributor,
        'level' => course.level
      )
    end
  end
end
