# frozen_string_literal: true

# == Schema Information
#
# Table name: categories
#
#  id              :integer          not null, primary key
#  name            :string
#  category_order  :integer
#  organization_id :integer
#  enabled         :boolean          default(TRUE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Category < ApplicationRecord
  belongs_to :organization
  has_many :courses

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
    return true unless organization.present?

    category_names = organization.categories.map(&:name)
    errors.add(:name, 'is already in use by your organization.') if category_names.include?(name)
  end
end
