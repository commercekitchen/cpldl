class AddLibraryCardLoginToOrganizations < ActiveRecord::Migration[4.2]
  def change
    add_column :organizations, :library_card_login, :boolean, default: false
  end
end
