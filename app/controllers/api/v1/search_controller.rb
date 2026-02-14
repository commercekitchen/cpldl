# frozen_string_literal: true

module Api
  module V1
    class SearchController < Api::V1::BaseController
      def index
        query = params[:q].presence

        courses = []
        if query.present?
          docs = PgSearch.multisearch(query)
                         .where(searchable_type: 'Course')
                         .limit(200)

          ids = docs.map(&:searchable_id).uniq

          scoped = policy_scope(Course)
                     .where(language: current_language, pub_status: %w[P C], id: ids)
                     .index_by(&:id)

          courses = ids.filter_map { |id| scoped[id] }
        end

        render json: {
          courses: courses.map { |c| CoursePresenter.new(c, user: current_user).as_json },
          lessons: []
        }
      end
    end
  end
end
