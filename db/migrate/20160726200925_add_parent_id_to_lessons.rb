class AddParentIdToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :parent_lesson_id, :integer
  end
end
