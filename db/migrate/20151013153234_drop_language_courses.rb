class DropLanguageCourses < ActiveRecord::Migration[4.2]
  def change
    drop_table :language_courses
  end
end
