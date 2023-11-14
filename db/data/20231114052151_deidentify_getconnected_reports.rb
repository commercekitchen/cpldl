class DeidentifyGetconnectedReports < ActiveRecord::Migration[5.2]
  def up
    Organization.find_by(subdomain: 'getconnected').update(deidentify_reports: true)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
