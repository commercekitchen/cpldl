class AddCkdAdminToCleveland < ActiveRecord::Migration[5.2]
  def up
    cleveland = Organization.find_by(subdomain: 'cleveland')
    AdminInvitationService.invite(email: 'susie+clevelandadmin@ckdtech.co', organization: cleveland)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
