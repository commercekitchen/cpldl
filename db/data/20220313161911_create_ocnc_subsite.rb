class CreateOcncSubsite < ActiveRecord::Migration[5.2]
  def up
    # Subsite Attributes
    subsite_attributes = {
      name: 'Orange County Public Library',
      subdomain: 'ocnc',
      branches: false,
      accepts_programs: false,
      accepts_partners: false
    }

    # Create the subdomain organization
    subsite = Organization.create!(subsite_attributes)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
