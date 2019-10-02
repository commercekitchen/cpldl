class MoveProgramRelatedFieldsFromProfileToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users,    :acting_as,           :string
    add_column :users,    :library_card_number, :string
    add_column :users,    :student_id,          :string
    add_column :users,    :date_of_birth,       :datetime
    add_column :users,    :grade,               :integer

    remove_column :profiles, :library_card_number, :string
    remove_column :profiles, :student_or_parent, :string
  end
end
