class AddLibraryCardLoginToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :library_card_login, :boolean, default: false
  end
end
