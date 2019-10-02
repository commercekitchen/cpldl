class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :first_name, null: false, limit: 30
      t.string :last_name, null: false, limit: 30
      t.string :organization, null: false, limit: 50
      t.string :city, null: false, limit: 30
      t.string :state, null: false, limit: 2
      t.string :email, null: false, limit: 30
      t.string :phone, limit: 20
      t.text :comments, null: false, limit: 2048
      t.timestamps null: false
    end
  end
end
