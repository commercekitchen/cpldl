class RemoveCourseUniquenessIndex < ActiveRecord::Migration[5.2]
  def change
    remove_index :courses, column: [:title, :organization_id]
  end
end
