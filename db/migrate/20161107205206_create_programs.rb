class CreatePrograms < ActiveRecord::Migration[4.2]
  def change
    create_table :programs do |t|
      t.string  :program_name
      t.string :location_field_name
      t.boolean :location_required, default: false
      t.boolean :student_program, default: false
      t.references :organization, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
