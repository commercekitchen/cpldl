class CreateProgramLocations < ActiveRecord::Migration[4.2]
  def change
    create_table :program_locations do |t|
      t.string :location_name
      t.timestamps null: false
      t.boolean :enabled, default: true
      t.references :program, index: true, foreign_key: true
    end
  end
end
