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

        def show
          lesson = @course.lessons.find(params[:id])
          authorize lesson, :update?
          render json: lesson_detail_payload(lesson)
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

        def update
          lesson = @course.lessons.find(params[:id])
          authorize lesson, :update?

          storyline_uploaded = params.dig(:lesson, :story_line_archive).present?

          if lesson.update(lesson_update_params)
            if storyline_uploaded && lesson.story_line_archive.attached?
              lesson.update_columns(
                storyline_unzip_status: Lesson.storyline_unzip_statuses[:queued],
                storyline_unzip_error: nil,
                storyline_unzip_failed_at: nil
              )
              lesson.enqueue_storyline_unzip
            end

            LessonPropagationService.new(lesson: lesson).update_children!
            render json: lesson_detail_payload(lesson.reload)
          else
            render status: :unprocessable_entity, json: { errors: lesson.errors.full_messages }
          end
        end

        def destroy
          lesson = @course.lessons.find(params[:id])
          authorize lesson
          lesson.destroy!

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

        def storyline_status
          lesson = @course.lessons.find(params[:id])
          authorize lesson, :update?
          render json: storyline_status_payload(lesson)
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

        def lesson_detail_payload(lesson)
          {
            id: lesson.id,
            title: lesson.title,
            summary: lesson.summary,
            duration: lesson.duration,
            lessonOrder: lesson.lesson_order,
            isAssessment: lesson.is_assessment,
            seoPageTitle: lesson.seo_page_title,
            metaDesc: lesson.meta_desc,
            storylineFilename: lesson.story_line_archive.attached? ? lesson.story_line_archive.filename.to_s : nil,
            storylineUnzipStatus: lesson.storyline_unzip_status,
            storylineUnzipError: lesson.storyline_unzip_error,
            storylineTracked: lesson.storyline_unzip_tracked?
          }
        end

        def storyline_status_payload(lesson)
          {
            storylineFilename: lesson.story_line_archive.attached? ? lesson.story_line_archive.filename.to_s : nil,
            storylineUnzipStatus: lesson.storyline_unzip_status,
            storylineUnzipError: lesson.storyline_unzip_error,
            storylineTracked: lesson.storyline_unzip_tracked?
          }
        end

        def lesson_create_params
          params.require(:lesson).permit(:title, :summary, :duration, :is_assessment)
        end

        def lesson_update_params
          params.require(:lesson).permit(
            :title, :summary, :duration, :seo_page_title, :meta_desc, :is_assessment, :story_line_archive
          )
        end
      end
    end
  end
end
