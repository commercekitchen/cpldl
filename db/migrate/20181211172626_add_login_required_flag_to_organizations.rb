class AddLoginRequiredFlagToOrganizations < ActiveRecord::Migration[4.2]
  def change
    add_column :organizations, :login_required, :boolean, default: true
  end
end
