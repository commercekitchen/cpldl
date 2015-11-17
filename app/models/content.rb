class Content < ActiveRecord::Base
  # belongs_to :languages
  belongs_to :cms_page
  belongs_to :language

  validates :language_id, presence: true
  # TODO: wire up connections in courses and lessons to use Contents
  # belongs_to :courses
  # belongs_to :lessons
end
