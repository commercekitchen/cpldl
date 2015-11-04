class CourseTopic < ActiveRecord::Base
  belongs_to :topic
  belongs_to :course, touch: true
end
