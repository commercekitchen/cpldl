class RemoveDeprecatedProgramLocationFieldName < ActiveRecord::Migration[4.2]
  def change
    remove_column :programs, :location_field_name, :string
  end
end
