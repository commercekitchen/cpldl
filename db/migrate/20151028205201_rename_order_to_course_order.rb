class RenameOrderToCourseOrder < ActiveRecord::Migration
  def change
    rename_column :lessons, :order, :lesson_order
  end
end
