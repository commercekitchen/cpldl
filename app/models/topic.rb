# frozen_string_literal: true

class Topic < ApplicationRecord
  has_many :course_topics, dependent: :destroy
  has_many :courses, through: :course_topics

  validates :title, presence: true
end
