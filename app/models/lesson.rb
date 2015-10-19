class Lesson < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  belongs_to :course
  validates :title, presence: true, length: { maximum: 90 }
  validates :title, :description, presence: true
  validates :duration, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :order, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
