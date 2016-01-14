class AddParentIdToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :parent_id, :integer
  end
end
