class RemoveDeprecatedProgramLocationFieldName < ActiveRecord::Migration
  def change
    remove_column :programs, :location_field_name, :string
  end
end
