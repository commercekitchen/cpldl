# frozen_string_literal: true

class Program < ApplicationRecord
  enum parent_type: { seniors: 0, adults: 1, young_adults: 2, students_and_parents: 3 }
  PARENT_TYPES = {
    'Programs for Seniors' => :seniors,
    'Programs for Adults' => :adults,
    'Programs for Young Adults' => :young_adults,
    'Programs for Students and Parents' => :students_and_parents
  }.freeze

  has_many :users, dependent: :nullify
  has_many :program_locations, dependent: :destroy
  belongs_to :organization
  validates :program_name, presence: true

  accepts_nested_attributes_for :program_locations

  scope :for_subdomain, ->(subdomain) { joins(:organization).where('organizations.subdomain = ?', subdomain) }
end
