# frozen_string_literal: true

module Api
  module V1
    module Admin
      class LessonsController < ::Api::V1::BaseController
        before_action :require_admin
        before_action :set_course

        def index
          lessons = @course.lessons.order(:lesson_order)
          render json: { lessons: lessons.map { |l| lesson_payload(l) } }
        end

        def create
          lesson = @course.lessons.build(lesson_create_params)
          lesson.lesson_order = @course.lessons.count + 1
          authorize lesson

          if lesson.save
            render json: lesson_payload(lesson), status: :created
          else
            render status: :unprocessable_entity, json: { errors: lesson.errors.full_messages }
          end
        end

        def destroy
          lesson = @course.lessons.find(params[:id])
          authorize lesson
          lesson.destroy!

          # Resequence remaining lessons and propagate order to child courses
          @course.lessons.order(:lesson_order).each_with_index do |l, i|
            l.update!(lesson_order: i + 1)
            LessonPropagationService.new(lesson: l).update_children!
          end

          head :no_content
        end

        def sort
          Array(params[:order]).each_with_index do |lesson_id, index|
            lesson = @course.lessons.find(lesson_id)
            authorize lesson, :update?
            lesson.update!(lesson_order: index + 1)
            LessonPropagationService.new(lesson: lesson).update_children!
          end
          head :ok
        end

        private

        def require_admin
          unless current_user&.admin?
            render status: :forbidden, json: { message: 'You are not authorized to perform this action.' }
          end
        end

        def set_course
          @course = current_organization.courses.find(params[:course_id])
        end

        def lesson_payload(lesson)
          {
            id: lesson.id,
            title: lesson.title,
            summary: lesson.summary,
            duration: lesson.duration,
            lessonOrder: lesson.lesson_order,
            isAssessment: lesson.is_assessment
          }
        end

        def lesson_create_params
          params.require(:lesson).permit(:title, :summary, :duration, :is_assessment)
        end
      end
    end
  end
end
