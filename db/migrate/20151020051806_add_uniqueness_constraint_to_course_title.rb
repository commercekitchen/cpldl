class AddUniquenessConstraintToCourseTitle < ActiveRecord::Migration[4.2]
  def change
    add_index :courses, :title, unique: true
  end
end
