# frozen_string_literal: true

# == Schema Information
#
# Table name: schools
#
#  id              :integer          not null, primary key
#  school_name     :string
#  enabled         :boolean          default(TRUE)
#  organization_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class School < ApplicationRecord
  has_many :profiles, dependent: :nullify
  belongs_to :organization

  validates :school_name, presence: true

  scope :enabled, -> { where(enabled: true) }
end
