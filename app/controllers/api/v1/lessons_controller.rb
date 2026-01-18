# frozen_string_literal: true

module Api
  module V1
    class LessonsController < Api::V1::BaseController
      def index
        lessons = Lesson.last(10)
        render json: LessonCollectionPresenter.new(lessons).as_json
      end

      def show
        lesson = Lesson.friendly.find(params[:id])
        render json: LessonPresenter.new(lesson).as_json
      end
    end
  end
end
