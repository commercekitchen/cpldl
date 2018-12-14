class QuizResponsesController < ApplicationController
  def new
  end

  def create
    current_user.update!(quiz_responses_object: quiz_params.to_h) unless current_user.quiz_responses_object.present?
    recommendation_service = CourseRecommendationService.new(current_organization.id, quiz_params)
    recommendation_service.add_recommended_courses(current_user.id)
    redirect_to my_courses_path
  end

  private

    def quiz_params
      params.permit("set_one", "set_two", "set_three")
    end

end
