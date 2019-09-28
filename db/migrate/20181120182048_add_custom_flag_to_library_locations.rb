class AddCustomFlagToLibraryLocations < ActiveRecord::Migration[4.2]
  def change
    add_column :library_locations, :custom, :boolean, default: false
  end
end
