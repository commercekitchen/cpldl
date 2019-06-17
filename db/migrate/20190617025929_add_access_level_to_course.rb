class AddAccessLevelToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :access_level, :integer, default: 0, null: false
  end
end
