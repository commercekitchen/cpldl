class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.text :body
      t.string :summary
      t.integer :language_id

      t.timestamps null: false
    end
  end
end
