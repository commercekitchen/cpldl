class Content < ActiveRecord::Base
  # belongs_to :languages
  belongs_to :cms_page, inverse_of: :contents

  attr_accessor :body, :language_id

  validates :body, presence: true
  # validates :language_id, presence: true
  # TODO: wire up connections in courses and lessons to use Contents
  # belongs_to :courses
  # belongs_to :lessons
end