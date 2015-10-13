class Course < ActiveRecord::Base
  has_many :course_topics
  has_many :topics, through: :course_topics

  belongs_to :language

  has_many :attachments, dependent: :destroy
  accepts_nested_attributes_for :attachments, reject_if: proc { |a| a[:attachment].blank? }, allow_destroy: true

  # has_many :lessons
  # has_one :assessment

  validates :title, :seo_page_title, :meta_desc, :summary, :description, :contributor, presence: true
  validates :pub_status, presence: true, inclusion: { in: %w(P), message: "%{value} is not a valid status" }
end
