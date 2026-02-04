# frozen_string_literal: true

class CourseCollectionPresenter
  def initialize(courses, user: nil)
    @courses = courses
    @user = user
  end

  def as_json(*)
    {
      courses: @courses.map { |c| CoursePresenter.new(c, user: @user).as_json }
    }
  end
end
