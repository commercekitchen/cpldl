# frozen_string_literal: true

class Category < ApplicationRecord
  belongs_to :organization
  has_many :courses, dependent: :nullify

  validates :name, presence: true
  validates :organization_id, presence: true

  validate :unique_org_categories, on: :create

  default_scope { order('enabled DESC, category_order ASC') }

  scope :enabled, -> { where(enabled: true) }
  scope :disabled, -> { where(enabled: false) }

  def admin_display_name
    self.name + (self.enabled ? '' : ' (disabled)')
  end

  private

  def unique_org_categories
    return true if organization.blank?

    category_names = organization.categories.map(&:name)
    errors.add(:name, 'is already in use by your organization.') if category_names.include?(name)
  end
end
