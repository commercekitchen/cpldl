# frozen_string_literal: true

class CompletedLesson < ApplicationRecord
  belongs_to :course_progress
end
