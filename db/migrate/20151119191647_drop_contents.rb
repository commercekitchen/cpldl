class DropContents < ActiveRecord::Migration[4.2]
  def change
    drop_table :contents
  end
end
