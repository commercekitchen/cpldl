# == Schema Information
#
# Table name: cms_pages
#
#  id             :integer          not null, primary key
#  title          :string(90)
#  author         :string
#  page_type      :string
#  audience       :string
#  pub_status     :string           default("D")
#  pub_date       :datetime
#  seo_page_title :string(90)
#  meta_desc      :string(156)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  slug           :string
#  cms_page_order :integer
#

class CmsPage < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  has_many :contents, dependent: :destroy
  accepts_nested_attributes_for :contents, allow_destroy: true

  validates :title, length: { maximum: 90 }, presence: true, uniqueness: true
  validates :seo_page_title, length: { maximum: 90 }
  validates :meta_desc, length: { maximum: 156 }
  validates :pub_status, presence: true,
    inclusion: { in: %w(P D T), message: "%{value} is not a valid status" }
  validates :author, presence: true
  validates :page_type, presence: true,
    inclusion: { in: %w(H C A O), message: "%{value} is not a valid page type" }
  validates :audience, presence: true,
    inclusion: { in: %w(Unauth Auth Admin All), message: "%{value} in not a valid audience" }

  default_scope { order("cms_page_order ASC") }

  def current_pub_status
    case pub_status
    when "D" then "Draft"
    when "P" then "Published"
    when "T" then "Trashed"
    end
  end

  def set_pub_date
    self.pub_date = Time.zone.now unless pub_status != "P"
  end

  def update_pub_date(new_pub_status)
    if new_pub_status == "P"
      self.pub_date = Time.zone.now
    else
      self.pub_date = nil
    end
  end
end
