# == Schema Information
#
# Table name: organization_courses
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  course_id       :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class OrganizationCourse < ActiveRecord::Base
  belongs_to :organization
  belongs_to :course
end
