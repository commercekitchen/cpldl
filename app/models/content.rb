# == Schema Information
#
# Table name: contents
#
#  id          :integer          not null, primary key
#  body        :text
#  summary     :string
#  language_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  cms_page_id :integer
#  course_id   :integer
#  lesson_id   :integer
#

class Content < ActiveRecord::Base
  # belongs_to :languages
  belongs_to :cms_page
  belongs_to :language

  validates :language_id, presence: true
  # TODO: wire up connections in courses and lessons to use Contents
  # belongs_to :courses
  # belongs_to :lessons
end
