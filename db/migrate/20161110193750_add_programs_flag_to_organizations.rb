class AddProgramsFlagToOrganizations < ActiveRecord::Migration[4.2]
  def change
    add_column :organizations, :accepts_programs, :boolean
  end
end
