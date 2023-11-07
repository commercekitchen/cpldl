# frozen_string_literal: true

class Topic < ApplicationRecord
  belongs_to :organization, optional: true
  has_many :course_topics, dependent: :destroy
  has_many :courses, through: :course_topics

  validates :title, presence: true

  scope :for_organization, -> (org) { where(organization: nil).or(where(organization: org)) }
end
