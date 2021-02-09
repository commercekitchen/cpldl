class CreateMdplsSubsite < ActiveRecord::Migration[5.2]
  def up
    # Subsite Attributes
    subsite_attributes = {
      name: 'Miami-Dade Public Library System',
      subdomain: 'mdpls',
      branches: true,
      accepts_programs: false,
      accepts_partners: false
    }

    # Admin users
    admins = ['fitosa@mdpls.org', 'campaj@mdpls.org']

    # Create the subdomain organization
    subsite = Organization.create!(subsite_attributes)

    # Invite Admins
    admins.each do |email|
      AdminInvitationService.invite(email: email, organization: subsite)
    end

    # Custom setup for branches, partners, etc. would go here...

    # Import all subsite courses
    Course.pla.where(pub_status: 'P').each do |course|
      CourseImportService.new(organization: subsite, course_id: course.id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
