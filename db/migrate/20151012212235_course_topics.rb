class CourseTopics < ActiveRecord::Migration[4.2]
  def change
    create_table :course_topics do |t|
      t.integer :topic_id
      t.integer :course_id

      t.timestamps null: false
    end
  end
end
