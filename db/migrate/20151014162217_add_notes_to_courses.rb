class AddNotesToCourses < ActiveRecord::Migration[4.2]
  def change
    add_column :courses, :notes, :text
  end
end
