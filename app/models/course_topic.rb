# == Schema Information
#
# Table name: course_topics
#
#  id         :integer          not null, primary key
#  topic_id   :integer
#  course_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CourseTopic < ApplicationRecord
  belongs_to :topic
  belongs_to :course, touch: true
end
