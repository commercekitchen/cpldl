class CreateCategories < ActiveRecord::Migration[4.2]
  def change
    create_table :categories do |t|
      t.string :name
      t.integer :category_order
      t.references :organization
      t.boolean :enabled, default: true
      t.timestamps null: false
    end

    add_reference :courses, :category, index: true
  end
end
