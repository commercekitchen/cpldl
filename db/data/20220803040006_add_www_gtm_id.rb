class AddWwwGtmId < ActiveRecord::Migration[5.2]
  def up
    # Organization.find_by(subdomain: 'www').update(gtm_id: 'GTM-MKC7DHG')
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
