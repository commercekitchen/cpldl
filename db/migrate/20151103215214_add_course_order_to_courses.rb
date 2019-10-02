class AddCourseOrderToCourses < ActiveRecord::Migration[4.2]
  def change
    add_column :courses, :course_order, :integer
  end
end
