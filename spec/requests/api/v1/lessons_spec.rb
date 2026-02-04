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
  end
end
