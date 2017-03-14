class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.integer :category_order
      t.references :organization
      t.timestamps null: false
    end

    add_reference :courses, :category, index: true
  end
end
