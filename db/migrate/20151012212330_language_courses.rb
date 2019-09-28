class LanguageCourses < ActiveRecord::Migration[4.2]
  def change
    create_table :language_courses do |t|
      t.integer :language_id
      t.integer :course_id

      t.timestamps null: false
    end
  end
end
