# frozen_string_literal: true

class CourseTopic < ApplicationRecord
  belongs_to :topic
  belongs_to :course, touch: true

  accepts_nested_attributes_for :topic, reject_if: :all_blank
end
