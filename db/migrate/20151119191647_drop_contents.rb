class DropContents < ActiveRecord::Migration
  def change
    drop_table :contents
  end
end
