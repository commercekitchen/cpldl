class AddNashvilleFieldsToUsersAndProfiles < ActiveRecord::Migration[4.2]
  def change
    add_column :profiles, :library_card_number, :string
    add_column :profiles, :student_or_parent,   :string
    add_column :profiles, :last_name,           :string
    add_column :profiles, :phone,               :string
    add_column :profiles, :street_address,      :string
    add_column :profiles, :city,                :string
    add_column :profiles, :state,               :string
  end
end
