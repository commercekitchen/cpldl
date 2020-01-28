# frozen_string_literal: true

class QuizResponsesController < ApplicationController
  before_action :authenticate_user!

  def new
    authorize current_organization, :get_recommendations?
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
    params.permit('set_one', 'set_two', 'set_three')
  end

end
