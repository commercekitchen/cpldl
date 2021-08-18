class AddComingSoonFlagToCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :coming_soon, :boolean, null: false, default: false
  end
end
