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

  enum publication_status: { draft: 0, published: 1, archived: 2 }

  # PgSearch gem config
  include PgSearch::Model
  multisearchable against: %i[title summary description topics_str level]

  pg_search_scope :topic_search, associated_against: { topics: :title },
                                 using: {
                                   tsearch: { any_word: true }
                                 }

  enum access_level: { everyone: 0, authenticated_users: 1 }

  # Attributes not saved to db, but still needed for validation
  attr_accessor :other_topic, :org_id, :subdomain

  belongs_to :parent, class_name: 'Course', optional: true
  has_one :course_progress, dependent: :restrict_with_exception

  has_many :course_topics, dependent: :destroy, inverse_of: :course
  has_many :topics, through: :course_topics
  has_many :lessons, -> { order(:lesson_order) }, dependent: :destroy, inverse_of: :course
  belongs_to :organization, optional: false
  has_many :attachments, dependent: :destroy
  accepts_nested_attributes_for :attachments,
                                reject_if: proc { |a| a[:document].blank? }, allow_destroy: true

  belongs_to :language
  belongs_to :category, optional: true

  accepts_nested_attributes_for :category, reject_if: :all_blank
  accepts_nested_attributes_for :course_topics, reject_if: proc { |ct| ct[:topic_attributes][:title].blank? }

  # Presence validations
  validates :title, :publication_status, presence: true
  validates :description,
            :contributor,
            :summary,
            :format,
            :level,
            :language_id, presence: true, unless: :draft?

  # Force coming_soon to false if draft
  validates :coming_soon, inclusion: { in: [false] }, unless: :draft?

  # Other Validations
  validates :title, length: { maximum: 50 }
  validates :title, uniqueness: { scope: :organization_id,
                                  conditions: -> { where.not(publication_status: :archived) },
                    message: 'has already been taken for the organization' }
  validates :seo_page_title, length: { maximum: 90 }
  validates :summary, length: { maximum: 74 }
  validates :meta_desc, length: { maximum: 156 }
  validates :format, inclusion: { in: %w[M D],
                                  message: '%<value>s is not a valid format',
                                  allow_blank: true }
  validates :level, inclusion: { in: %w[Beginner Intermediate Advanced],
                                 message: '%<value>s is not a valid level',
                                 allow_blank: true }

  default_scope { order('course_order ASC') }

  scope :with_category, ->(category_id) { where(category_id: category_id) }
  scope :copied_from_course, ->(course) { joins(:organization).where(parent_id: course.id) }
  scope :org, ->(org) { where(organization: org) }
  scope :pla, -> { where(organization: Organization.find_by(subdomain: 'www')) }
  scope :visible_to_users, -> { where(publication_status: :published) }

  before_save :find_or_create_category
  after_save :update_publication_date

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
    raise StandardError, 'There are no available lessons for this course.' if lessons.count.zero?

    begin
      lesson_order = lesson.lesson_order
      return lessons.last if lesson_order >= last_lesson_order

      lessons.find_by('lesson_order > ?', lesson_order)
    rescue StandardError
      lessons.first
    end
  end

  def last_lesson_order
    raise StandardError, 'There are no available lessons for this course.' if lessons.count.zero?

    lessons.maximum('lesson_order')
  end

  def duration(format = 'mins')
    total = 0
    lessons.each { |l| total += l.duration }
    Duration.minutes_str(total, format)
  end

  def additional_resource_attachments
    self.attachments.where(doc_type: 'additional-resource')
  end

  def text_copy_attachments
    (parent || self).attachments.where(doc_type: 'text-copy')
  end

  def find_or_create_category
    return true if category_name.blank?

    existing_category = self.organization.categories.find_by('lower(name) = ?', category_name.downcase)
    self.category = existing_category || self.organization.categories.find_or_create_by(name: category_name)
  end

  def self.publication_status_options
    self.publication_statuses.keys.map { |status| [status.titleize, status] }
  end

  private

  def update_publication_date
    if saved_change_to_publication_status? && published?
      update(pub_date: Time.zone.now)
    end
  end
end
