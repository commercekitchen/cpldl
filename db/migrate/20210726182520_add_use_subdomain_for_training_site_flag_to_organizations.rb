class AddUseSubdomainForTrainingSiteFlagToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :use_subdomain_for_training_site, :boolean, default: false, null: false
  end
end
