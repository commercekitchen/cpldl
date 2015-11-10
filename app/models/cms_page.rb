class CmsPage < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  validates :title, length: { maximum: 90 }, presence: true, uniqueness: true
  validates :seo_page_title, length: { maximum: 90 }
  validates :content, presence: true
  validates :meta_desc, length: { maximum: 156 }
  validates :pub_status, presence: true,
    inclusion: { in: %w(P D T), message: "%{value} is not a valid status" }
  validates :author, presence: true
  validates :page_type, presence: true,
    inclusion: { in: %w(H C A O), message: "%{value} is not a valid page type" }
  validates :audience, presence: true,
    inclusion: { in: %w(Unauth Auth Admin All), message: "%{value} in not a valid audience" }

  private

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