# frozen_string_literal: true

class CourseRecommendationSurveysController < ApplicationController
  before_action :authenticate_user!

  def new
    authorize current_organization, :get_recommendations?

    if !current_organization.custom_recommendation_survey
      # This keeps the topics in order, although it's less efficient
      @topics = []
      topic_translation_keys.each do |key|
        @topics << Topic.find_by(translation_key: key)
      end
      @topics.compact!
    end
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
    params.permit(:desktop_level, :mobile_level, :topic)
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
