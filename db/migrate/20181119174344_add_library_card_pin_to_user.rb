class AddLibraryCardPinToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :library_card_pin, :string
  end
end
