# frozen_string_literal: true

# TODO: deprecated

class OrganizationCourse < ApplicationRecord
  belongs_to :organization
  belongs_to :course
end
