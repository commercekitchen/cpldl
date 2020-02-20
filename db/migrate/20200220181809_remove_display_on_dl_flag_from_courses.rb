class RemoveDisplayOnDlFlagFromCourses < ActiveRecord::Migration[5.2]
  def change
    remove_column :courses, :display_on_dl, :boolean, default: false
  end
end
