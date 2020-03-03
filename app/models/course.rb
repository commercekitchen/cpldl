# frozen_string_literal: true

class Course < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: %i[slugged history]

  attr_accessor :category_name

  def slug_candidates
    [
      :title,
      %i[title subdomain_for_slug]
    ]
  end

  def subdomain_for_slug
    subdomain
  end

  # PgSearch gem config
  include PgSearch::Model
  multisearchable against: %i[title summary description topics_str level]

  pg_search_scope :topic_search, associated_against: { topics: :title },
                                 using: {
                                   tsearch: { any_word: true }
                                 }

  enum access_level: { everyone: 0, authenticated_users: 1 }
  # Attributes not saved to db, but still needed for validation
  attr_accessor :other_topic, :other_topic_text, :org_id, :subdomain
  attr_writer :propagation_org_ids

  belongs_to :parent, class_name: 'Course', optional: true
  # has_one :assessment
  has_one :course_progress, dependent: :restrict_with_exception

  has_many :course_topics, dependent: :destroy
  has_many :topics, through: :course_topics
  has_many :lessons, -> { order(:lesson_order) }, dependent: :destroy, inverse_of: :course
  belongs_to :organization, optional: false
  has_many :attachments, dependent: :destroy
  accepts_nested_attributes_for :attachments,
                                reject_if: proc { |a| a[:document].blank? }, allow_destroy: true

  belongs_to :language
  belongs_to :category, optional: true

  accepts_nested_attributes_for :category, reject_if: :all_blank

  validates :description, :contributor, :language_id, presence: true
  validates :title, length: { maximum: 50 }, presence: true
  validates :title, uniqueness: { scope: :organization_id,
    conditions: -> { where.not(pub_status: 'A') }, message: 'has already been taken for the organization' }
  validates :seo_page_title, length: { maximum: 90 }
  validates :summary, length: { maximum: 74 }, presence: true
  validates :meta_desc, length: { maximum: 156 }
  validates :format, presence: true,
    inclusion: { in: %w[M D], message: '%<value>s is not a valid format', allow_blank: true }
  validates :pub_status, presence: true,
    inclusion: { in: %w[P D A], message: '%<value>s is not a valid status', allow_blank: true }
  validates :level, presence: true,
    inclusion: { in: %w[Beginner Intermediate Advanced],
      message: '%<value>s is not a valid level' }
  validates :other_topic_text, presence: true, if: proc { |a| a.other_topic == '1' }

  default_scope { order('course_order ASC') }

  scope :with_category, ->(category_id) { where(category_id: category_id) }
  scope :copied_from_course, ->(course) { joins(:organization).where(parent_id: course.id, organizations: { id: course.propagation_org_ids }) }
  scope :org, ->(org) { where(organization: org) }
  scope :pla, -> { where(organization: Organization.find_by(subdomain: 'www')) }
  scope :published, -> { where(pub_status: 'P') }

  before_save :find_or_create_category

  def propagation_org_ids
    @propagation_org_ids ||= []
  end

  def topics_list(topic_list)
    if topic_list.present?
      valid_topics = topic_list.reject(&:blank?)
      new_or_found_topics = valid_topics.map do |title|
        Topic.find_or_create_by(title: title)
      end
      self.topics = new_or_found_topics
    end
  end

  def topics_str
    topics.pluck(:title).join(', ')
  end

  def lesson_after(lesson = nil)
    raise StandardError, 'There are no available lessons for this course.' if lessons.published.count.zero?

    begin
      lesson_order = lesson.lesson_order
      return lessons.published.last if lesson_order >= last_lesson_order

      lessons.published.find_by('lesson_order > ?', lesson_order)
    rescue StandardError
      lessons.published.first
    end
  end

  def last_lesson_order
    raise StandardError, 'There are no available lessons for this course.' if lessons.count.zero?

    lessons.maximum('lesson_order')
  end

  def duration(format = 'mins')
    total = 0
    lessons.published.each { |l| total += l.duration }
    Duration.minutes_str(total, format)
  end

  def set_pub_date
    self.pub_date = Time.zone.now unless pub_status != 'P'
  end

  def update_pub_date(new_pub_status)
    self.pub_date = if new_pub_status == 'P'
                      Time.zone.now
                    end
  end

  def update_lesson_pub_stats(new_pub_status)
    lessons.each do |l|
      l.pub_status = new_pub_status
      l.save
    end
  end

  def post_course_attachments
    self.attachments.where(doc_type: 'post-course')
  end

  def supplemental_attachments
    self.attachments.where(doc_type: 'supplemental')
  end

  def published?
    pub_status == 'P'
  end

  def find_or_create_category
    return true if category_name.blank?

    existing_category = self.organization.categories.find_by('lower(name) = ?', category_name.downcase)
    self.category = existing_category || self.organization.categories.find_or_create_by(name: category_name)
  end
end
