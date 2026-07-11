# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::CourseRecommendationSurveys', type: :request do
  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, organization: organization) }
  let(:choices) { { desktop_level: 'Beginner', mobile_level: 'Beginner', topic: '' } }

  before do
    host! "#{organization.subdomain}.test.host"
    login_as(user, scope: :user)
  end

  describe 'POST /api/v1/course_recommendation_survey' do
    context 'with an invalid profile' do
      # Bypass validation to simulate a profile that became invalid outside the app.
      before { user.profile.update_column(:first_name, nil) } # rubocop:disable Rails/SkipsModelValidations

      it 'returns 422 with an invalid_profile error instead of raising' do
        post '/api/v1/course_recommendation_survey', params: choices

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('invalid_profile')
      end

      it 'does not persist quiz responses' do
        post '/api/v1/course_recommendation_survey', params: choices

        expect(user.reload.quiz_responses_object).to be_blank
      end
    end

    context 'with a valid profile' do
      it 'saves quiz responses and succeeds' do
        post '/api/v1/course_recommendation_survey', params: choices

        expect(response).to have_http_status(:ok)
        expect(user.reload.quiz_responses_object).to eq(choices.stringify_keys)
      end
    end
  end
end
