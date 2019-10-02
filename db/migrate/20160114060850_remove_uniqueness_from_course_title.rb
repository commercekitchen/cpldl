class RemoveUniquenessFromCourseTitle < ActiveRecord::Migration
  def change
    remove_index :courses, :title
    add_index :courses, :title
  end
end
