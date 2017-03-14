class Category < ActiveRecord::Base
  belongs_to :organization
  has_many :courses

  validates :name, presence: true
  validates :organization_id, presence: true

  validate :unique_org_categories
  validate :unique_org_category_order

  private

  def unique_org_categories
    return true unless organization.present?
    category_names = organization.categories.map(&:name)
    errors.add(:name, "is already in use by your organization") if category_names.include?(name)
  end
  
  def unique_org_category_order
    return true unless category_order.present?
    category_orders = organization.categories.map(&:category_order)
    errors.add(:category_order, "is already in use by your organization") if category_orders.include?(category_order)
  end
end