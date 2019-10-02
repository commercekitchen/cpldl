class AddProgramsFlagToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :accepts_programs, :boolean
  end
end
