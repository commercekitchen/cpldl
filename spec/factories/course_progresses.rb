FactoryGirl.define do
  factory(:course_progress) do
  end

  factory(:course_progress_with_completed_lessons) do
    after(:create) do |course_progress|
      create(:completed_lesson, course_progress: course_progress)
      create(:completed_lesson, course_progress: course_progress)
      create(:completed_lesson, course_progress: course_progress)
    end
  end
end
