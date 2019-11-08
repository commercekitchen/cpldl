# frozen_string_literal: true

class CourseTopic < ApplicationRecord
  belongs_to :topic
  belongs_to :course, touch: true
end
