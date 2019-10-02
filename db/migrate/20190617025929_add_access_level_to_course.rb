class AddAccessLevelToCourse < ActiveRecord::Migration[4.2]
  def change
    add_column :courses, :access_level, :integer, default: 0, null: false
  end
end
