class OrganizationCourse < ActiveRecord::Base
  belongs_to :organization
  belongs_to :course
end
