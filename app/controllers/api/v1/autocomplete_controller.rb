# frozen_string_literal: true

module Api
  module V1
    class AutocompleteController < Api::V1::BaseController
      COURSE_LIMIT = 10
      LESSON_LIMIT = 10

      def index
        query = params[:query].presence || params[:q].presence

        if query.blank?
          return render json: { query: query.to_s, suggestions: [] }
        end

        visible_courses = policy_scope(Course)
                          .where(language: current_language, pub_status: %w[P C])

        courses = visible_courses
                  .autocomplete(query)
                  .order(:title)
                  .limit(COURSE_LIMIT)

        lessons = Lesson
                  .joins(:course)
                  .merge(visible_courses)
                  .where('lessons.title ILIKE ?', "%#{ActiveRecord::Base.sanitize_sql_like(query)}%")
                  .order(:title)
                  .limit(LESSON_LIMIT)

        suggestions = courses.map do |course|
          { type: 'course', id: course.id, label: course.title, hint: 'Course' }
        end

        suggestions += lessons.map do |lesson|
          { type: 'lesson', id: lesson.id, label: lesson.title, hint: 'Lesson' }
        end

        render json: { query: query, suggestions: suggestions }
      end
    end
  end
end
