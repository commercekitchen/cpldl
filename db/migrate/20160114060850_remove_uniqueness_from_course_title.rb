class RemoveUniquenessFromCourseTitle < ActiveRecord::Migration[4.2]
  def change
    remove_index :courses, :title
    add_index :courses, :title
  end
end
