class CreateCourseProgresses < ActiveRecord::Migration[4.2]
  def change
    create_table :course_progresses do |t|
      t.integer :user_id
      t.integer :course_id
      t.integer :lessons_completed, default: 0
      t.timestamp :started_at
      t.timestamp :completed_at
      t.timestamps null: false
    end
  end
end
