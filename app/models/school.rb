# frozen_string_literal: true

class School < ApplicationRecord
  has_many :profiles, dependent: :nullify
  belongs_to :organization

  validates :school_name, presence: true

  scope :enabled, -> { where(enabled: true) }
end
