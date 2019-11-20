# frozen_string_literal: true

class CreateClevelandOrganization < ActiveRecord::Migration[5.2]
  def up
    cleveland = Organization.create!(name: 'Cleveland Foundation', subdomain: 'cleveland', accepts_partners: true)

    AdminInvitationService.invite(email: 'cwilliams@clevefdn.org', organization: cleveland)

    ['Cleveland Public Library',
     'Cuyahoga County Public Library',
     'East Cleveland Public Library',
     'Cuyahoga Metropolitan Housing Authority',
     'CHN Housing Partners',
     'DigitalC',
     'Ashbury Senior Computer Community Center',
     'PCs for People',
     'Other'].each do |partner|
      cleveland.partners.create!(name: partner)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
