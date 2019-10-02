class AddTitleUniqueIndexToCourses < ActiveRecord::Migration
  def change
    add_index :courses, [:title, :organization_id], unique: true
  end
end
