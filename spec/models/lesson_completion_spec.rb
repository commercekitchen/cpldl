# frozen_string_literal: true

require 'rails_helper'

describe LessonCompletion do
  it { should belong_to(:course_progress) }
  it { should belong_to(:lesson) }

  describe 'course completion' do
    let(:course) { FactoryBot.create(:course_with_lessons) }
    let(:course_progress) { FactoryBot.create(:course_progress, course: course) }

    it 'does not mark the course progress complete until every lesson is completed' do
      first, second, = course.lessons.order(:lesson_order)

      expect do
        LessonCompletion.create(course_progress: course_progress, lesson: first)
      end.not_to change(course_progress, :completed_at)

      expect do
        LessonCompletion.create(course_progress: course_progress, lesson: second)
      end.not_to change(course_progress, :completed_at)
    end

    it 'marks the course progress complete once every lesson is completed, regardless of order' do
      lessons = course.lessons.order(:lesson_order).to_a.reverse

      lessons[0..-2].each do |lesson|
        FactoryBot.create(:lesson_completion, course_progress: course_progress, lesson: lesson)
      end

      expect do
        LessonCompletion.create(course_progress: course_progress, lesson: lessons.last)
      end.to change(course_progress, :completed_at).from(nil)
    end

    it 'does not mark the course complete just because the assessment lesson was completed' do
      assessment = FactoryBot.create(:lesson, course: course, is_assessment: true, lesson_order: 99)

      expect do
        LessonCompletion.create(course_progress: course_progress, lesson: assessment)
      end.not_to change(course_progress, :completed_at)
    end
  end
end
