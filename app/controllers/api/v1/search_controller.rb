# frozen_string_literal: true

module Api
  module V1
    class SearchController < Api::V1::BaseController
      def index
        query = params[:q].presence

        courses = []
        lessons = []

        if query.present?
          docs = PgSearch.multisearch(query).limit(200)

          course_ids = docs.where(searchable_type: 'Course').map(&:searchable_id).uniq
          lesson_ids = docs.where(searchable_type: 'Lesson').map(&:searchable_id).uniq

          scoped_courses = policy_scope(Course)
                             .where(language: current_language, pub_status: %w[P C], id: course_ids)
                             .index_by(&:id)
          courses = course_ids.filter_map { |id| scoped_courses[id] }

          scoped_lessons = Lesson
                             .joins(:course)
                             .where(id: lesson_ids,
                                    courses: {
                                      organization_id: current_organization.id,
                                      language: current_language,
                                      pub_status: %w[P C]
                                    })
                             .index_by(&:id)
          lessons = lesson_ids.filter_map { |id| scoped_lessons[id] }
        end

        render json: {
          courses: courses.map { |c| CoursePresenter.new(c, user: current_user).as_json },
          lessons: lessons.map { |l| LessonPresenter.new(l, user: current_user).as_json }
        }
      end
    end
  end
end
