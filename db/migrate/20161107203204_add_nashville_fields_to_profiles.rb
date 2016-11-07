class AddNashvilleFieldsToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :last_name,           :string
    add_column :profiles, :phone,               :string
    add_column :profiles, :street_address,      :string
    add_column :profiles, :city,                :string
    add_column :profiles, :state,               :string
    add_column :profiles, :library_card_number, :string
    add_column :profiles, :student_id,          :string
    add_column :profiles, :date_of_birth,       :datetime
    add_column :profiles, :grade,               :integer
  end
end
