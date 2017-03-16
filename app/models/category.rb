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

class Category < ActiveRecord::Base
  belongs_to :organization
  has_many :courses

  validates :name, presence: true
  validates :organization_id, presence: true

  validate :unique_org_categories, on: :create
  validate :unique_org_category_order

  default_scope { order("category_order ASC") }

  scope :enabled, -> { where(enabled: true) }

  private

  def unique_org_categories
    return true unless organization.present?
    category_names = organization.categories.map(&:name)
    errors.add(:name, "is already in use by your organization.") if category_names.include?(name)
  end
  
  def unique_org_category_order
    return true unless category_order.present?
    category_orders = organization.categories.map(&:category_order)
    errors.add(:category_order, "is already in use by your organization.") if category_orders.include?(category_order)
  end
end
