class AddCourseOrderToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :course_order, :integer
  end
end
