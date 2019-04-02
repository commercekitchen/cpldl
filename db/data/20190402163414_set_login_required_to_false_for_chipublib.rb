class SetLoginRequiredToFalseForChipublib < ActiveRecord::Migration
  def up
    # chipublib subdomain should not require login to view lessons
    Organization.find_by(subdomain: "chipublib").update(login_required: false)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
