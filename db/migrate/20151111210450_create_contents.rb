class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.text :body
      t.integer :lanugage_id

      t.timestamps null: false
    end
  end
end
