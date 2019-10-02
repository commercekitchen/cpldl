class AddSortOrderToLibraryLocations < ActiveRecord::Migration[4.2]
  def change
    add_column :library_locations, :sort_order, :integer, default: 0
  end
end
