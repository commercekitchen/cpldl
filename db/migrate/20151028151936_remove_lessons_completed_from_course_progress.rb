class RemoveLessonsCompletedFromCourseProgress < ActiveRecord::Migration
  def change
    remove_column :course_progresses, :lessons_completed, :string
  end
end
