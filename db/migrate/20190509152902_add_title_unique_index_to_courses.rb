class AddTitleUniqueIndexToCourses < ActiveRecord::Migration[4.2]
  def change
    add_index :courses, [:title, :organization_id], unique: true
  end
end
