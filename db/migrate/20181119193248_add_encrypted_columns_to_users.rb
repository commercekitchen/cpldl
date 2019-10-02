class AddEncryptedColumnsToUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :library_card_pin, :string
    add_column :users, :encrypted_library_card_pin, :string
    add_column :users, :encrypted_library_card_pin_iv, :string
  end
end
