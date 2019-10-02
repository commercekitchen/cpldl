class SetLoginRequiredToFalseForNpl < ActiveRecord::Migration[4.2]
  def up
    Organization.find_by(subdomain: "npl").update(login_required: false)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
