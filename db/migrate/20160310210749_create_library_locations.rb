class CreateLibraryLocations < ActiveRecord::Migration[4.2]
  def change
    create_table :library_locations do |t|
      t.string :name
      t.integer :zipcode
      t.timestamps null: false
    end
  end
end
