# frozen_string_literal: true

class ProgramLocation < ApplicationRecord
  belongs_to :program
  has_many :users, dependent: :nullify
  validates :location_name, presence: true

  scope :enabled, -> { where(enabled: true) }
end
