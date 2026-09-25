# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Courses', type: :request do
  describe 'GET /api/v1/courses' do
    let(:organization) { create(:organization) }
    let(:language) { create(:language) }

    before do
      host! "#{organization.subdomain}.test.host"
    end

    around do |example|
      I18n.with_locale(:en) { example.run }
    end

    it 'returns published and coming soon courses for the current org and language' do
      published_course = create(
        :course,
        organization: organization,
        language: language,
        pub_status: 'P',
        access_level: :everyone,
        summary: 'Published summary',
        description: 'Published description'
      )
      coming_soon_course = create(
        :course,
        organization: organization,
        language: language,
        pub_status: 'C',
        access_level: :everyone,
        summary: 'Coming soon summary',
        description: 'Coming soon description'
      )
      create(:draft_course, organization: organization, language: language, access_level: :everyone)
      create(:course, organization: organization, language: language, access_level: :authenticated_users)
      create(:course, organization: create(:organization), language: language, access_level: :everyone)
      create(:course, organization: organization, language: create(:spanish_lang), access_level: :everyone)

      get '/api/v1/courses'

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      course_payloads = body.fetch('courses')

      expect(course_payloads.size).to eq(2)
      expect(course_payloads.map { |course| course['summary'] }).to match_array(
        [published_course.summary, coming_soon_course.summary]
      )
      expect(course_payloads).to include(
        hash_including(
          'summary' => published_course.summary,
          'description' => published_course.description
        )
      )
    end

    it 'filters courses by category' do
      category = create(:category, organization: organization)
      other_category = create(:category, organization: organization)

      create(
        :course,
        organization: organization,
        language: language,
        pub_status: 'P',
        access_level: :everyone,
        category: category,
        summary: 'Category match'
      )
      create(
        :course,
        organization: organization,
        language: language,
        pub_status: 'P',
        access_level: :everyone,
        category: other_category,
        summary: 'Other category'
      )

      get '/api/v1/courses', params: { category_id: category.id }

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      course_payloads = body.fetch('courses')

      expect(course_payloads.size).to eq(1)
      expect(course_payloads.first['summary']).to eq('Category match')
    end

    it 'returns an empty list for scope=completed when there is no current user' do
      create(:course, organization: organization, language: language, pub_status: 'P', access_level: :everyone)

      get '/api/v1/courses', params: { scope: 'completed' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).fetch('courses')).to be_empty
    end

    it 'returns only the current user\'s completed courses for scope=completed' do
      user = create(:user, organization: organization)
      completed_course = create(
        :course,
        organization: organization,
        language: language,
        pub_status: 'P',
        access_level: :everyone,
        summary: 'Completed course'
      )
      incomplete_course = create(
        :course,
        organization: organization,
        language: language,
        pub_status: 'P',
        access_level: :everyone,
        summary: 'Incomplete course'
      )
      create(:course_progress, user: user, course: completed_course, completed_at: Time.current)
      create(:course_progress, user: user, course: incomplete_course, completed_at: nil)
      allow_any_instance_of(Api::V1::CoursesController).to receive(:current_user).and_return(user)

      get '/api/v1/courses', params: { scope: 'completed' }

      expect(response).to have_http_status(:ok)

      course_payloads = JSON.parse(response.body).fetch('courses')

      expect(course_payloads.size).to eq(1)
      expect(course_payloads.first['summary']).to eq('Completed course')
    end
  end
end
