class AddOrganizationIdToCourse < ActiveRecord::Migration
  def change
    add_reference :courses, :organization, index: true
    OrganizationCourse.find_each do |org_course|
      org_course.course&.update(organization: org_course.organization)
    end
  end
end
