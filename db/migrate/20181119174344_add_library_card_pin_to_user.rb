class AddLibraryCardPinToUser < ActiveRecord::Migration
  def change
    add_column :users, :library_card_pin, :string
  end
end
