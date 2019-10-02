class AddCustomFlagToLibraryLocations < ActiveRecord::Migration
  def change
    add_column :library_locations, :custom, :boolean, default: false
  end
end
