# frozen_string_literal: true

module Api
  module V1
    class CoursesController < Api::V1::BaseController
      def index
        courses = policy_scope(Course).where(language: current_language, pub_status: %w[P C]).order(updated_at: :desc)

        if params[:category_id].present?
          courses = courses.joins(:category).where(categories: { id: params[:category_id] })
        end

        if params[:scope] == 'tracked'
          return render json: { courses: [] } unless current_user

          tracked_course_ids = current_user.course_progresses.tracked.pluck(:course_id)
          courses = courses.where(id: tracked_course_ids)
        end

        render json: CourseCollectionPresenter.new(courses, user: current_user).as_json
      end

      def show
        course = Course.friendly.find(params[:id])
        render json: CoursePresenter.new(course, user: current_user).as_json
      end
    end
  end
end
