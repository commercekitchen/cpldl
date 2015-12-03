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

require 'rails_helper'

RSpec.describe OrganizationCourse, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
