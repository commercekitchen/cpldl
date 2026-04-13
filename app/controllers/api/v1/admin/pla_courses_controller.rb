# frozen_string_literal: true

module Api
  module V1
    module Admin
      class PlaCoursesController < ::Api::V1::BaseController
        before_action :require_admin

        def index
          authorize current_organization, :import_courses?

          pla_courses = Course.pla.where(pub_status: 'P').includes(:category, :topics, :language)
          imported_by_parent_id = imported_courses_by_parent_id

          courses = pla_courses.map do |course|
            imported = imported_by_parent_id[course.id]
            {
              id: course.id,
              title: course.title,
              category: course.category&.name,
              topics: course.topics.map(&:title),
              language: course.language&.name,
              imported: imported.present?,
              importedCourseId: imported&.id,
              importedPubStatus: imported&.pub_status
            }
          end

          render json: { courses: courses }
        end

        def import
          authorize current_organization, :import_courses?

          import_service = CourseImportService.new(
            organization: current_organization,
            course_id: params[:id].to_i
          )
          new_course = import_service.import!

          render json: { importedCourseId: new_course.id, importedPubStatus: new_course.pub_status }
        rescue CourseImportService::ImportError => e
          render status: :unprocessable_entity, json: { message: e.message }
        end

        def pub_status
          course = current_organization.courses.find(params[:id])
          authorize course, :update?

          unless Course.pub_status_options.map(&:last).include?(params[:pub_status])
            render status: :unprocessable_entity, json: { message: 'Invalid publication status.' }
            return
          end

          course.update!(pub_status: params[:pub_status])
          render json: { importedPubStatus: course.pub_status }
        end

        private

        def require_admin
          unless current_user&.admin?
            render status: :forbidden, json: { message: 'You are not authorized to perform this action.' }
          end
        end

        def imported_courses_by_parent_id
          current_organization.courses
            .where.not(pub_status: 'A')
            .where.not(parent_id: nil)
            .index_by(&:parent_id)
        end
      end
    end
  end
end
