class Course < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  # Attributes not saved to db, but still needed for validation
  attr_accessor :other_topic, :other_topic_text

  # has_one :assessment
  has_many :course_topics
  has_many :topics, through: :course_topics
  has_many :lessons
  has_many :attachments, dependent: :destroy

  belongs_to :language

  accepts_nested_attributes_for :attachments,
    reject_if: proc { |a| a[:document].blank? }, allow_destroy: true

  validates :description, :contributor, :language_id, presence: true
  validates :title, length: { maximum: 90 }, presence: true, uniqueness: true
  validates :seo_page_title, length: { maximum: 90 }
  validates :summary, length: { maximum: 156 }, presence: true
  validates :meta_desc, length: { maximum: 156 }
  validates :pub_status, presence: true,
    inclusion: { in: %w(P D T), message: "%{value} is not a valid status" }
  validates :level, presence: true,
    inclusion: { in: %w(Beginner Intermediate Advanced),
      message: "%{value} is not a valid level" }
  validates_presence_of :other_topic_text, if: Proc.new { |a| a.other_topic == "1" }

  def topics_list(topic_list)
    if topic_list.present?
      valid_topics = topic_list.reject(&:blank?)
      new_or_found_topics = valid_topics.map do |title|
        Topic.find_or_create_by(title: title)
      end
      self.topics = new_or_found_topics
    end
  end
end
