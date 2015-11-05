# == Schema Information
#
# Table name: lessons
#
#  id                      :integer          not null, primary key
#  lesson_order            :integer
#  title                   :string(90)
#  duration                :integer
#  course_id               :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  slug                    :string
#  summary                 :string(156)
#  story_line              :string(156)
#  seo_page_title          :string(90)
#  meta_desc               :string(156)
#  is_assessment           :boolean
#  story_line_file_name    :string
#  story_line_content_type :string
#  story_line_file_size    :integer
#  story_line_updated_at   :datetime
#

require "zip"

class Lesson < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  belongs_to :course

  # TODO: We need to make lesson titles unique per course, but not site-wide.
  validates :title, length: { maximum: 90 }, presence: true # , uniqueness: true
  validates :summary, length: { maximum: 156 }, presence: true
  validates :duration, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :lesson_order, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :seo_page_title, length: { maximum: 90 }
  validates :meta_desc, length: { maximum: 156 }

  # validates :story_line, attachment_presence: true
  # validates_with AttachmentPresenceValidator, attributes: :story_line

  has_attached_file :story_line, url: "/system/lessons/story_lines/:id/:style/:basename.:extension"
  before_post_process :skip_for_zip
  validates_attachment_content_type :story_line, content_type: ["application/zip", "application/x-zip"],
                                                      message: ", Please provide a .zip Articulate StoryLine File."

  before_destroy :delete_associated_asl_files

  default_scope { order("lesson_order") }

  def skip_for_zip
    ! %w(application/zip application/x-zip).include?(story_line_content_type)
  end

  def delete_associated_asl_files
    FileUtils.remove_dir "#{Rails.root}/public/storylines/#{id}", true
  end

  def duration_str
    Duration.duration_str(duration)
  end

  def duration_to_int(duration_param)
    if duration_param.include?(":")
      self.duration = Duration.duration_str_to_int(duration_param)
    else
      self.duration = duration_param.to_i
    end
  end
end
