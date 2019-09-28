class RemoveLessonsCompletedFromCourseProgress < ActiveRecord::Migration[4.2]
  def change
    remove_column :course_progresses, :lessons_completed, :string
  end
end
