# frozen_string_literal: true

class Category < ApplicationRecord
  belongs_to :organization
  has_many :courses, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :organization, message: 'is already in use by your organization.' }

  default_scope { order('enabled DESC, category_order ASC') }

  scope :enabled, -> { where(enabled: true) }
  scope :disabled, -> { where(enabled: false) }

  def admin_display_name
    self.name + (self.enabled ? '' : ' (disabled)')
  end
end
