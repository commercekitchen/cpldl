class AddLevelToCourses < ActiveRecord::Migration[4.2]
  def change
    add_column :courses, :level, :string
  end
end
