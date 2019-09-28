class AddTrackedToCourseProgress < ActiveRecord::Migration[4.2]
  def change
    add_column :course_progresses, :tracked, :boolean, default: false
  end
end
