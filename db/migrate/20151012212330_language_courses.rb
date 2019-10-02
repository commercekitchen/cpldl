class LanguageCourses < ActiveRecord::Migration
  def change
    create_table :language_courses do |t|
      t.integer :language_id
      t.integer :course_id

      t.timestamps null: false
    end
  end
end
