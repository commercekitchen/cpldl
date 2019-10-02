class DropLanguageCourses < ActiveRecord::Migration
  def change
    drop_table :language_courses
  end
end
