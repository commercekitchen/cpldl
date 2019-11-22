class CreatePartners < ActiveRecord::Migration[5.2]
  def change
    create_table :partners do |t|
      t.belongs_to :organization, index: true
      t.string :name, null: false, default: ""

      t.timestamps null: false
    end
  end
end
