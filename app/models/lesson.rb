class Lesson < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  belongs_to :course
  validates :title, presence: true, length: { maximum: 90 }
  validates :summary, presence: true, length: { maximum: 156 }
  validates :duration, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :lesson_order, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :seo_page_title, length: { maximum: 90 }
  validates :meta_desc, length: { maximum: 156 }
end
