class SetLoginRequiredToFalseForNpl < ActiveRecord::Migration
  def up
    Organization.find_by(subdomain: "npl").update(login_required: false)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
