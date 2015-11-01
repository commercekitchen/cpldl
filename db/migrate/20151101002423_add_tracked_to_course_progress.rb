class AddTrackedToCourseProgress < ActiveRecord::Migration
  def change
    add_column :course_progresses, :tracked, :boolean, default: false
  end
end
