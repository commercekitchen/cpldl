# frozen_string_literal: true

class CourseRecommendationSurveysController < ApplicationController
  before_action :authenticate_user!

  def new
    authorize current_organization, :get_recommendations?
    @topics = Topic.where(translation_key: topic_translation_keys)
  end

  def create
    authorize current_organization, :get_recommendations?
    current_user.update!(quiz_responses_object: quiz_params.to_h) if current_user.quiz_responses_object.blank?
    recommendation_service = CourseRecommendationService.new(current_organization.id, quiz_params)
    recommendation_service.add_recommended_courses(current_user.id)
    redirect_to my_courses_path
  end

  private

  def quiz_params
    params.permit('desktop_level', 'mobile_level', 'topics' => [])
  end

  def topic_translation_keys
    ['job_search',
     'education_child',
     'govt',
     'education_adult',
     'communication_social_media',
     'security',
     'software_apps',
     'information_searching']
  end
end
