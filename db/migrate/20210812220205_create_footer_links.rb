class CreateFooterLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :footer_links do |t|
      t.belongs_to :organization

      t.string :label, null: false
      t.string :url, null: false

      t.timestamps
    end
  end
end
