# frozen_string_literal: true

require 'rails_helper'

describe CourseProgress do

  context '#complete?' do
    let(:course_progress) { FactoryBot.create(:course_progress) }

    it 'should be false if there is no completed date' do
      expect(course_progress.complete?).to be false
    end

    it 'should be true when a completed_at time is present' do
      course_progress.completed_at = Time.zone.now
      expect(course_progress.complete?).to be true
    end
  end

  context 'scope completed' do
    let(:user) { FactoryBot.create(:user) }
    let(:course1) { FactoryBot.create(:course, title: 'Course 1') }
    let(:course2) { FactoryBot.create(:course, title: 'Course 2') }
    let(:course3) { FactoryBot.create(:course, title: 'Course 3') }

    let(:course_progress1) do
      FactoryBot.create(:course_progress, course: course1, tracked: true, completed_at: Time.zone.now, user: user)
    end

    let(:course_progress2) do
      FactoryBot.create(:course_progress, course: course2, tracked: true, user: user)
    end

    let(:course_progress3) do
      FactoryBot.create(:course_progress, course: course3, tracked: true, completed_at: Time.zone.now, user: user)
    end

    it 'should be false if there is no completed date' do
      expect(user.course_progresses.completed).to include(course_progress1, course_progress3)
    end
  end

  context '#percent_complete' do
    let(:course) { FactoryBot.create(:course_with_lessons) }
    let(:course_progress) { FactoryBot.create(:course_progress, course: course) }
    let(:completed_lesson1) { FactoryBot.create(:lesson_completion, lesson: course.lessons.first) }
    let(:completed_lesson2) { FactoryBot.create(:lesson_completion, lesson: course.lessons.second) }
    let(:completed_lesson3) { FactoryBot.create(:lesson_completion, lesson: course.lessons.third) }

    it 'should be 0 when not started' do
      expect(course_progress.percent_complete).to eq(0)
    end

    it 'should be 33 when 1 of 3 is completed' do
      course_progress.lesson_completions << [completed_lesson1]
      expect(course_progress.percent_complete).to eq(33)
    end

    it 'should be 100 when 3 of 3 are completed' do
      course_progress.lesson_completions << [completed_lesson1, completed_lesson2, completed_lesson3]
      expect(course_progress.percent_complete).to eq(100)
    end
  end

  context '#next_lesson' do
    let(:course) { FactoryBot.create(:course_with_lessons) }
    let(:course_progress) { FactoryBot.create(:course_progress, course: course) }
    let!(:completed_lesson1) { FactoryBot.create(:lesson_completion, lesson: course.lessons.first) }
    let!(:completed_lesson2) { FactoryBot.create(:lesson_completion, lesson: course.lessons.second) }
    let!(:completed_lesson3) { FactoryBot.create(:lesson_completion, lesson: course.lessons.third) }

    it 'should give first lesson id when not started' do
      expect(course_progress.next_lesson).to eq(course.lessons.first)
    end

    it 'should give the next uncomplted lesson_id when started' do
      course_progress.lesson_completions << [completed_lesson1]
      expect(course_progress.next_lesson).to eq(course.lessons.second)
    end

    it 'should give the last lesson_id if course is complete' do
      course_progress.lesson_completions << [completed_lesson1, completed_lesson2, completed_lesson3]
      expect(course_progress.next_lesson).to eq(course.lessons.third)
    end

    it 'should give the third lesson_id even if only course 2 is completed' do
      course_progress.lesson_completions << [completed_lesson2]
      expect(course_progress.next_lesson).to eq(course.lessons.third)
    end

    it 'should throw an error if a course has no lessons' do
      course.lessons.destroy_all
      expect { course_progress.next_lesson }.to raise_error(StandardError)
    end
  end
end
