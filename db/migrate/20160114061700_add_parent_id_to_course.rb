class AddParentIdToCourse < ActiveRecord::Migration[4.2]
  def change
    add_column :courses, :parent_id, :integer
  end
end
