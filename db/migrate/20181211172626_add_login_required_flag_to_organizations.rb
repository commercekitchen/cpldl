class AddLoginRequiredFlagToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :login_required, :boolean, default: true
  end
end
