class AddThemeDataToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :theme_data, :jsonb
  end
end
