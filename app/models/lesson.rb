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
  validates :title, length: { maximum: 90 }, presence: true # , uniqueness: true
  validates :summary, length: { maximum: 156 }, presence: true
  validates :duration, presence: true, numericality: { only_integer: true, greater_than: 0, allow_blank: true }
  validates :lesson_order, presence: true, numericality: { only_integer: true, greater_than: 0, allow_blank: true }
  validates :seo_page_title, length: { maximum: 90 }
  validates :meta_desc, length: { maximum: 156 }

  has_attached_file :story_line, Rails.configuration.storyline_paperclip_opts
  before_post_process :skip_for_zip
  validates_attachment_content_type :story_line, content_type: ['application/zip', 'application/x-zip'],
                                                      message: ', Please provide a .zip Articulate StoryLine File.'

  before_destroy :delete_associated_asl_files

  default_scope { order(:lesson_order) }
  scope :copied_from_lesson, ->(lesson) { joins(course: :organization).where(parent_id: lesson.id) }

  def skip_for_zip
    %w[application/zip application/x-zip].include?(story_line_content_type)
  end

  def delete_associated_asl_files
    FileUtils.remove_dir "#{Rails.root}/public/storylines/#{id}", true
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

end
