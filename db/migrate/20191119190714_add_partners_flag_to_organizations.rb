class AddPartnersFlagToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :accepts_partners, :boolean, default: false
  end
end
