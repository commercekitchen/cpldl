class AddBelongsToOrganizationOnLibraryLocation < ActiveRecord::Migration[4.2]
  def change
    add_reference :library_locations, :organization, index: true, foreign_key: true

    chipublib = Organization.find_by(subdomain: "chipublib")
    demo = Organization.find_by(subdomain: "demo")

    if chipublib && demo
      LibraryLocation.all.each do |ll|
        new_library_location = ll.clone
        new_library_location.organization_id = demo.id
        new_library_location.save

        ll.organization_id = chipublib.id
        ll.save
      end
    elsif chipublib
      LibraryLocation.all.each do |ll|
        ll.organization_id = chipublib.id
        ll.save
      end
    end
  end
end
