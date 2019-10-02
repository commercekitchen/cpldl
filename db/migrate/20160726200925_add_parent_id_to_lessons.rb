class AddParentIdToLessons < ActiveRecord::Migration[4.2]
  def change
    add_column :lessons, :parent_lesson_id, :integer
  end
end
