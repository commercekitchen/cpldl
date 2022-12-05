class CreateResourceLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :resource_links do |t|
      t.belongs_to :course

      t.string :label, null: false
      t.string :url, null: false

      t.timestamps
    end
  end
end
