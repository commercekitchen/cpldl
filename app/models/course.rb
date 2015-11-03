class Course < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  # PgSearch gem config
  include PgSearch
  multisearchable against: [:title, :summary, :description, :topics]

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
  validates :other_topic_text, presence: true, if: proc { |a| a.other_topic == "1" }

  def topics_list(topic_list)
    if topic_list.present?
      valid_topics = topic_list.reject(&:blank?)
      new_or_found_topics = valid_topics.map do |title|
        Topic.find_or_create_by(title: title)
      end
      self.topics = new_or_found_topics
    end
  end

  def topics_list
    topics.pluck(:title).join(", ")
  end

  def next_lesson_id(current_lesson_id = 0)
    fail StandardError, "There are no available lessons for this course." if lessons.count == 0

    begin
      current_lesson = lessons.find(current_lesson_id)
      order = current_lesson.lesson_order
      order += 1
      return lessons.order("lesson_order").last.id if order >= last_lesson_order
      next_lesson = lessons.find_by_lesson_order(order)
      next_lesson.id
    rescue
      lessons.order("lesson_order").first.id
    end
  end

  def last_lesson_order
    fail StandardError, "There are no available lessons for this course." if lessons.count == 0
    lessons.maximum("lesson_order")
  end

  def duration
    total = 0
    lessons.each { |l| total += l.duration }
    Duration.minutes_str(total)
  end

end
