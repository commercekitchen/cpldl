# frozen_string_literal: true

class LessonCollectionPresenter
  def initialize(lessons, user: nil)
    @lessons = lessons
    @user = user
  end

  def as_json(*)
    {
      lessons: @lessons.map { |l| LessonPresenter.new(l, user: @user).as_json }
    }
  end
end
