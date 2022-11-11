class CreateGetconnectedSubsite < ActiveRecord::Migration[5.2]
  def up
    # Subsite Attributes
    subsite_attributes = {
      name: 'Get Connected!',
      subdomain: 'getconnected',
      branches: false,
      accepts_programs: false,
      accepts_partners: false
    }

    # Create the subdomain organization
    subsite = Organization.find_or_create_by!(subdomain: subsite_attributes[:subdomain], name: subsite_attributes[:name])
    subsite.update!(subsite_attributes)

    # Import all subsite courses
    Course.pla.where(pub_status: 'P').each do |course|
      next if subsite.courses.where(title: course.title).present?
      CourseImportService.new(organization: subsite, course_id: course.id).import!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
