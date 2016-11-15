class AddNashvilleFieldsToUsersAndProfiles < ActiveRecord::Migration
  def change
    add_column :users,    :acting_as,           :string
    add_column :users,    :library_card_number, :string
    add_column :users,    :student_id,          :string
    add_column :users,    :date_of_birth,       :datetime
    add_column :users,    :grade,               :integer
    add_column :profiles, :last_name,           :string
    add_column :profiles, :phone,               :string
    add_column :profiles, :street_address,      :string
    add_column :profiles, :city,                :string
    add_column :profiles, :state,               :string
  end
end
