# frozen_string_literal: true

# == Schema Information
#
# Table name: program_locations
#
#  id            :integer          not null, primary key
#  location_name :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  enabled       :boolean          default(TRUE)
#  program_id    :integer
#

class ProgramLocation < ApplicationRecord
  belongs_to :program
  has_many :users
  validates :location_name, presence: true

  scope :enabled, -> { where(enabled: true) }
end
