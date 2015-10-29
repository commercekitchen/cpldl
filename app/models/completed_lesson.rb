class CompletedLesson < ActiveRecord::Base
  belongs_to :course_progress
end
