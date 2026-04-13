# frozen_string_literal: true

module Api
  module V1
    class LessonsController < Api::V1::BaseController
      def index
        lessons = fetch_lessons_for_index
        render json: LessonCollectionPresenter.new(lessons, user: current_user).as_json
      end

      def show
        lesson = policy_scope(Lesson).friendly.find(params[:id])
        render json: LessonPresenter.new(lesson, user: current_user).as_json
      end

      def complete
        course = Course.friendly.find(params[:course_id])
        lesson = course.lessons.friendly.find(params[:lesson_id])

        authorize_completion(course, lesson)

        course_progress = update_course_progress(course, lesson)

        render status: :ok, json: {
          redirect_path: completion_redirect_path(course, lesson),
          course_completed: course_progress&.reload&.complete? || false
        }
      end

      private

      def authorize_completion(course, lesson)
        if preview_request?
          authorize course, :preview?
        else
          authorize lesson, :show?
        end
      end

      def completion_redirect_path(course, lesson)
        if lesson.is_assessment
          preview_request? ? admin_course_preview_path(course) : course_completion_path(course)
        else
          course_lesson_lesson_complete_path(course, lesson, preview: params[:preview])
        end
      end

      def preview_request?
        params[:preview].present?
      end

      def update_course_progress(course, lesson)
        if current_user
          course_progress = CourseProgress.find_or_create_by!(user: current_user, course: course)
          LessonCompletion.find_or_create_by!(course_progress: course_progress, lesson: lesson)
          course_progress
        elsif respond_to?(:session)
          session[:completed_lessons] ||= []
          session[:completed_lessons] << lesson.id unless session[:completed_lessons].include?(lesson.id)
          nil
        end
      end

      def fetch_lessons_for_index
        return policy_scope(Lesson).where(course_id: params[:course_id]) if params[:course_id].present?
        return scoped_lessons if scope_or_limit_present?

        Lesson.none
      end

      def scope_or_limit_present?
        params[:scope].present? || params[:limit].present?
      end

      def scoped_lessons
        lessons = lessons_for_scope(requested_scope)
        lessons = apply_limit(lessons)
        apply_language(lessons)
      end

      def requested_scope
        params[:scope].presence || 'all'
      end

      def lessons_for_scope(scope)
        case scope
        when 'popular'
          lessons_for_popular_scope
        when 'all'
          lessons_for_all_scope
        when 'recommended'
          lessons_for_recommended_scope
        when 'newest'
          lessons_for_newest_scope
        else
          lessons_for_all_scope
        end
      end

      def apply_limit(lessons)
        limit = parsed_limit || 10

        lessons.limit(limit)
      end

      def apply_language(lessons)
        lessons.joins(:course).where(courses: { language: current_language })
      end

      def parsed_limit
        return nil if params[:limit].blank?

        limit = params[:limit].to_i
        return nil if limit <= 0

        limit
      end

      def lessons_for_popular_scope
        recent_counts = LessonCompletion
                        .where('created_at > ?', 1.year.ago)
                        .group(:lesson_id)
                        .select('lesson_id, COUNT(*) AS completion_count')

        policy_scope(Lesson)
          .joins("LEFT JOIN (#{recent_counts.to_sql}) AS recent_completions ON recent_completions.lesson_id = lessons.id")
          .order('COALESCE(recent_completions.completion_count, 0) DESC')
      end

      def lessons_for_all_scope
        policy_scope(Lesson)
      end

      def lessons_for_recommended_scope
        # Do we need this?
        policy_scope(Lesson)
      end

      def lessons_for_newest_scope
        policy_scope(Lesson).order(created_at: :desc)
      end
    end
  end
end
