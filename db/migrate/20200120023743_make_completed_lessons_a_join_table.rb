class MakeCompletedLessonsAJoinTable < ActiveRecord::Migration[5.2]
  def change
    add_index :completed_lessons, :lesson_id
    add_foreign_key :completed_lessons, :lessons
    rename_table :completed_lessons, :lesson_completions
  end
end
