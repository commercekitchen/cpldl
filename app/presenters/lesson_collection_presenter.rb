# frozen_string_literal: true

class LessonCollectionPresenter
  def initialize(lessons, current_user: nil)
    @lessons = lessons
    @current_user = current_user
  end

  def as_json(*)
    {
      lessons: @lessons.map { |l| LessonPresenter.new(l, current_user: @current_user).as_json }
    }
  end
end
