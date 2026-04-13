# frozen_string_literal: true

module Api
  module V1
    module Admin
      class CoursesController < ::Api::V1::BaseController
        before_action :require_admin

        def index
          courses = current_organization.courses.includes(:category, :topics, :language)
          render json: { courses: courses.map { |c| course_payload(c) } }
        end

        def pub_status
          course = current_organization.courses.find(params[:id])
          authorize course, :update?

          unless Course.pub_status_options.map(&:last).include?(params[:pub_status])
            render status: :unprocessable_entity, json: { message: 'Invalid publication status.' }
            return
          end

          course.update!(pub_status: params[:pub_status])
          render json: { pubStatus: course.pub_status }
        end

        private

        def require_admin
          unless current_user&.admin?
            render status: :forbidden, json: { message: 'You are not authorized to perform this action.' }
          end
        end

        def course_payload(course)
          {
            id: course.id,
            title: course.title,
            category: course.category&.name,
            topics: course.topics.map(&:title),
            language: course.language&.name,
            imported: course.imported_course?,
            pubStatus: course.pub_status
          }
        end
      end
    end
  end
end
