# frozen_string_literal: true

class School < ApplicationRecord
  has_many :profiles, dependent: :nullify
  belongs_to :organization

  validates :school_name, presence: true

  enum school_type: { elementary: 0, middle: 1, high: 2, charter: 3, specialty: 4 }

  scope :enabled, -> { where(enabled: true) }
end
