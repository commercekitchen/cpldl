# frozen_string_literal: true

class School < ApplicationRecord
  has_many :profiles, dependent: :nullify
  belongs_to :organization

  validates :school_name, presence: true

  enum school_type: { elementary: 0, middle_school: 1, high_school: 2 }

  scope :enabled, -> { where(enabled: true) }
end
