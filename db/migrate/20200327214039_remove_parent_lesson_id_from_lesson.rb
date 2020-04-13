class RemoveParentLessonIdFromLesson < ActiveRecord::Migration[5.2]
  def change
    remove_column :lessons, :parent_lesson_id, :integer
  end
end
