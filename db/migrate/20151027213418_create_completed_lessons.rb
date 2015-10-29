class CreateCompletedLessons < ActiveRecord::Migration
  def change
    create_table :completed_lessons do |t|
      t.integer :course_progress_id
      t.integer :lesson_id
      t.timestamps null: false
    end
  end
end
