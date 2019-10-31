# frozen_string_literal: true

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

# TODO: deprecated

class OrganizationCourse < ApplicationRecord
  belongs_to :organization
  belongs_to :course
end
