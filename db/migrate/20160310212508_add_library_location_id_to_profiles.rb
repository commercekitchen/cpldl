class AddLibraryLocationIdToProfiles < ActiveRecord::Migration[4.2]
  def change
    add_column :profiles, :library_location_id, :integer
  end
end
