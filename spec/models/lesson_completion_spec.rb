# frozen_string_literal: true

require 'rails_helper'

describe LessonCompletion do
  it { should belong_to(:course_progress) }
  it { should belong_to(:lesson) }

  describe 'course completion' do
    let(:course_progress) { FactoryBot.create(:course_progress) }
    let(:lesson) { FactoryBot.create(:lesson, course: course_progress.course, is_assessment: true) }

    it 'should update course progress created_at if lesson completion' do
      expect do
        LessonCompletion.create(course_progress: course_progress, lesson: lesson)
      end.to change(course_progress, :completed_at)
    end
  end
end
