class AddNotesToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :notes, :text
  end
end
