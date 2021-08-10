class CreateAttSubsite < ActiveRecord::Migration[5.2]
  def up
    # Subsite Attributes
    subsite_attributes = {
      name: 'AT&T',
      subdomain: 'att',
      branches: false,
      accepts_programs: false,
      accepts_partners: false
    }

    # Admin users
    admins = ['susie+att_admin@ckdtech.co,
               alex+att_admin@ckdtech.co,
               tom+att_admin@ckdtech.co']

    # Create the subdomain organization
    subsite = Organization.create!(subsite_attributes)

    # Invite Admins
    admins.each do |email|
      AdminInvitationService.invite(email: email, organization: subsite)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
