class CreateOcncSubsite < ActiveRecord::Migration[5.2]
  def up
    # Subsite Attributes
    subsite_attributes = {
      name: 'Orange County Public Library',
      subdomain: 'ocnc',
      branches: false,
      accepts_programs: false,
      accepts_partners: true
    }

    # Create the subdomain organization
    subsite = Organization.find_or_create_by!(subdomain: subsite_attributes[:subdomain])
    subsite.update!(subsite_attributes)

    # Create partners
    ['Orange County Public Library', 'CWS', 'Other'].each do |partner|
      subsite.partners.find_or_create_by!(name: partner)
    end

    # Import all subsite courses
    Course.pla.where(pub_status: 'P').each do |course|
      CourseImportService.new(organization: subsite, course_id: course.id).import!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
