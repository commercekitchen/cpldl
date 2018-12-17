class SetLoginRequiredToFalseForWww < ActiveRecord::Migration
  def up
    # www subdomain should not require login to view lessons
    Organization.find_by(subdomain: 'www').update(login_required: false)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
