# frozen_string_literal: true

module Api
  module V1
    class CoursesController < Api::V1::BaseController
      def index
        courses = policy_scope(Course).where(language: current_language, pub_status: %w[P C])

        category_id = params[:category_id]
        if category_id.present?
          courses = courses.joins(:category).where(categories: { id: category_id })
        end

        render json: CourseCollectionPresenter.new(courses).as_json
      end

      def show
        course = Course.friendly.find(params[:id])
        render json: CoursePresenter.new(course).as_json
      end
    end
  end
end
