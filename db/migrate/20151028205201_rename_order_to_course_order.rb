class RenameOrderToCourseOrder < ActiveRecord::Migration[4.2]
  def change
    rename_column :lessons, :order, :lesson_order
  end
end
