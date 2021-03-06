class CreateTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :translations do |t|
      t.string :locale
      t.string :key
      t.text :value
      t.text :interpolations
      t.boolean :is_proc

      t.timestamps null: false
    end
  end
end
