# == Schema Information
#
# Table name: completed_lessons
#
#  id                 :integer          not null, primary key
#  course_progress_id :integer
#  lesson_id          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class CompletedLesson < ActiveRecord::Base
  belongs_to :course_progress
end
