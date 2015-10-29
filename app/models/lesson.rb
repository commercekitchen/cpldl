require "zip"

class Lesson < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  belongs_to :course

  validates :title, length: { maximum: 90 }, presence: true #, uniqueness: true
  validates :summary, length: { maximum: 156 }, presence: true
  validates :duration, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :lesson_order, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :seo_page_title, length: { maximum: 90 }
  validates :meta_desc, length: { maximum: 156 }

  # validates :story_line, attachment_presence: true
  validates_with AttachmentPresenceValidator, attributes: :story_line

  has_attached_file :story_line, url: "/system/lessons/story_lines/:id/:style/:basename.:extension"
  before_post_process :skip_for_zip
  validates_attachment_content_type :story_line, content_type: ["application/zip", "application/x-zip"],
                                                      message: ", Please provide a .zip Articulate StoryLine File."

  before_destroy :delete_associated_asl_files

  def skip_for_zip
    ! %w(application/zip application/x-zip).include?(story_line_content_type)
  end

  def delete_associated_asl_files
    FileUtils.remove_dir "#{Rails.root}/public/storylines/#{self.id}", true
  end
end
