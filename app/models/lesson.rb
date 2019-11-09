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
  attr_writer :propagation_org_ids

  belongs_to :course
  belongs_to :parent, class_name: 'Lesson', optional: true

  # TODO: We need to make lesson titles unique per course, but not site-wide.
  validates :title, length: { maximum: 90 }, presence: true # , uniqueness: true
  validates :summary, length: { maximum: 156 }, presence: true
  validates :duration, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :lesson_order, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :seo_page_title, length: { maximum: 90 }
  validates :meta_desc, length: { maximum: 156 }
  validates :pub_status, presence: true,
    inclusion: { in: %w[P D A], message: '%<value>s is not a valid status' }

  has_attached_file :story_line, url: '/system/lessons/story_lines/:id/:style/:basename.:extension'
  before_post_process :skip_for_zip
  validates_attachment_content_type :story_line, content_type: ['application/zip', 'application/x-zip'],
                                                      message: ', Please provide a .zip Articulate StoryLine File.'

  before_destroy :delete_associated_asl_files
  before_destroy :delete_associated_user_completions

  default_scope { order(:lesson_order) }
  scope :published, -> { where(pub_status: 'P') }
  scope :copied_from_lesson, lambda { |lesson|
    joins(course: :organization)
      .where(parent_id: lesson.id, organizations: { id: lesson.propagation_org_ids })
  }

  def propagation_org_ids
    @propagation_org_ids ||= []
  end

  def skip_for_zip
    %w[application/zip application/x-zip].include?(story_line_content_type)
  end

  def delete_associated_asl_files
    FileUtils.remove_dir "#{Rails.root}/public/storylines/#{id}", true
  end

  def delete_associated_user_completions
    completions = CompletedLesson.where(lesson_id: id)
    completions.each(&:destroy)
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

  def published?
    pub_status == 'P'
  end

  def published_lesson_order
    return 0 unless self.published?

    self.course.lessons.published.map(&:id).index(self.id) + 1
  end

end
