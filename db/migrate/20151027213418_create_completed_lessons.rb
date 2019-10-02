class CreateCompletedLessons < ActiveRecord::Migration[4.2]
  def change
    create_table :completed_lessons do |t|
      t.integer :course_progress_id
      t.integer :lesson_id
      t.timestamps null: false
    end
  end
end
