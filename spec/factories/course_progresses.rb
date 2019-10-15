# frozen_string_literal: true

# == Schema Information
#
# Table name: course_progresses
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  course_id    :integer
#  started_at   :datetime
#  completed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  tracked      :boolean          default(FALSE)
#

FactoryBot.define do
  factory(:course_progress) do
    user
    course
  end

  factory(:course_progress_with_completed_lessons) do
    after(:create) do |course_progress|
      create(:completed_lesson, course_progress: course_progress)
      create(:completed_lesson, course_progress: course_progress)
      create(:completed_lesson, course_progress: course_progress)
    end
  end
end
