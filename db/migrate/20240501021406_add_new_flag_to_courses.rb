class AddNewFlagToCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :new_course, :bool, null: false, default: false
  end
end
