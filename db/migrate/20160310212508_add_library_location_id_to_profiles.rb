class AddLibraryLocationIdToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :library_location_id, :integer
  end
end
