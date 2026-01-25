# frozen_string_literal: true

require 'zip'

class Lesson < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: %i[slugged history]

  def slug_candidates
    [
      :title,
      %i[title subdomain_for_slug]
    ]
  end

  def subdomain_for_slug
    subdomain
  end

  attr_accessor :subdomain

  belongs_to :course
  belongs_to :parent, class_name: 'Lesson', optional: true
  has_many :lesson_completions, dependent: :destroy

  # TODO: We need to make lesson titles unique per course, but not site-wide.
  validates :title, length: { maximum: 100 }, presence: true # , uniqueness: true
  validates :summary, length: { maximum: 255 }, presence: true
  validates :duration, presence: true, numericality: { only_integer: true, greater_than: 0, allow_blank: true }
  validates :lesson_order, presence: true, numericality: { only_integer: true, greater_than: 0, allow_blank: true }
  validates :seo_page_title, length: { maximum: 90 }
  validates :meta_desc, length: { maximum: 156 }

  has_attached_file :story_line, Rails.configuration.storyline_paperclip_opts
  validates_attachment_content_type :story_line, content_type: ['application/zip', 'application/x-zip'],
                                                      message: ', Please provide a .zip Articulate StoryLine File.'

  has_one_attached :story_line_archive

  attr_accessor :storyline_archive_assigned

  # TODO: Swap for Rails 7+
  after_commit :enqueue_storyline_unzip, on: %i[create update], if: :storyline_archive_assigned? # < 7
  # after_commit :enqueue_storyline_unzip, on: %i[create update], if: :saved_change_to_story_line_archive_attachment? 7+

  default_scope { order(:lesson_order) }
  scope :copied_from_lesson, ->(lesson) { joins(course: :organization).where(parent_id: lesson.id) }

  enum storyline_unzip_status: {
    queued: 0,
    processing: 1,
    complete: 2,
    failed: 3
  }, _prefix: true

  def story_line_archive=(attachable)
    self.storyline_archive_assigned = true
    super
  end

  def duration_str
    Duration.duration_str(duration)
  end

  def duration_to_int(duration_param)
    self.duration = if duration_param.include?(':')
                      Duration.duration_str_to_int(duration_param)
                    else
                      duration_param.to_i
                    end
  end

  def effective_storyline_lesson
    parent || self
  end

  def story_line_directory
    effective = effective_storyline_lesson

    # ActiveStorage first
    if effective.respond_to?(:story_line_archive) && effective.story_line_archive.attached?
      name = effective.story_line_archive.filename.to_s
      return name.sub(/\.zip\z/i, "") if name.present?
    end

    # Paperclip fallback (migration window only)
    if effective.respond_to?(:story_line_file_name) && effective.story_line_file_name.present?
      return effective.story_line_file_name.sub(/\.zip\z/i, "")
    end

    nil
  end

  def storyline_root_path
    dir = story_line_directory
    return nil if dir.blank?

    effective = effective_storyline_lesson
    "storylines/#{effective.id}/#{dir}"
  end

  def storyline_entry_path
    root = storyline_root_path
    return nil if root.blank?

    "#{root}/story.html"
  end

  def storyline_unzip_tracked?
    !storyline_unzip_status.nil?
  end

  private

  def storyline_archive_assigned?
    storyline_archive_assigned
  end

  def enqueue_storyline_unzip
    return if parent_id.present?
    return unless story_line_archive.attached?
    return if story_line_directory.blank?

    UnzipStorylineJob.perform_later(id)
  end
end
