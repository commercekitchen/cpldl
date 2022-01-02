class AddOrganizationIdToCourse < ActiveRecord::Migration[4.2]
  def change
    add_reference :courses, :organization, index: true

    begin
      OrganizationCourse.find_each do |org_course|
        next if org_course.course.nil?
        org_course.course.update(organization: org_course.organization)
      end
    rescue NameError
      puts "OrganizationCourse no longer defined"
    end
  end
end
