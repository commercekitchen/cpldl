# frozen_string_literal: true

require 'rails_helper'

describe CourseProgress do

  context '#complete?' do

    before(:each) do
      @course_progress = FactoryBot.create(:course_progress)
    end

    it 'should be false if there is no completed date' do
      expect(@course_progress.complete?).to be false
    end

    it 'should be true when a completed_at time is present' do
      @course_progress.completed_at = Time.zone.now
      expect(@course_progress.complete?).to be true
    end

  end

  context 'scope completed' do

    before(:each) do
      @user = FactoryBot.create(:user)
      @course1 = FactoryBot.create(:course, title: 'Course 1')
      @course2 = FactoryBot.create(:course, title: 'Course 2')
      @course3 = FactoryBot.create(:course, title: 'Course 3')
      @course_progress1 = FactoryBot.create(:course_progress, course_id: @course1.id,
                                                               tracked: true,
                                                               completed_at: Time.zone.now)
      @course_progress2 = FactoryBot.create(:course_progress, course_id: @course2.id,
                                                               tracked: true)
      @course_progress3 = FactoryBot.create(:course_progress, course_id: @course3.id,
                                                               tracked: true,
                                                               completed_at: Time.zone.now)
      @user.course_progresses << [@course_progress1, @course_progress2, @course_progress3]
    end

    it 'should be false if there is no completed date' do
      expect(@user.course_progresses.completed).to include(@course_progress1, @course_progress3)
    end

  end

  context '#percent_complete' do

    before(:each) do
      @course1 = FactoryBot.create(:course)
      @lesson1 = FactoryBot.create(:lesson)
      @lesson2 = FactoryBot.create(:lesson)
      @lesson3 = FactoryBot.create(:lesson)
      @course1.lessons << [@lesson1, @lesson2, @lesson3]
      @course_progress = FactoryBot.create(:course_progress, course_id: @course1.id)
      @completed_lesson1 = FactoryBot.create(:completed_lesson, lesson_id: @lesson1.id)
      @completed_lesson2 = FactoryBot.create(:completed_lesson, lesson_id: @lesson2.id)
      @completed_lesson3 = FactoryBot.create(:completed_lesson, lesson_id: @lesson3.id)
    end

    it 'should be 0 when not started' do
      expect(@course_progress.percent_complete).to eq(0)
    end

    it 'should be 33 when 1 of 3 is completed' do
      @course_progress.completed_lessons << [@completed_lesson1]
      expect(@course_progress.percent_complete).to eq(33)
    end

    it 'should be 100 when 3 of 3 are completed' do
      @course_progress.completed_lessons << [@completed_lesson1, @completed_lesson2, @completed_lesson3]
      expect(@course_progress.percent_complete).to eq(100)
    end

  end

  context '#next_lesson_id' do

    before(:each) do
      @course = FactoryBot.create(:course_with_lessons)
      @course_progress = FactoryBot.create(:course_progress, course_id: @course.id)
      @completed_lesson1 = FactoryBot.create(:completed_lesson, lesson_id: @course.lessons.first.id)
      @completed_lesson2 = FactoryBot.create(:completed_lesson, lesson_id: @course.lessons.second.id)
      @completed_lesson3 = FactoryBot.create(:completed_lesson, lesson_id: @course.lessons.third.id)
    end

    it 'should give first lesson id when not started' do
      expect(@course_progress.next_lesson_id).to eq(@course.lessons.where(lesson_order: 1).first.id)
    end

    it 'should give the next uncomplted lesson_id when started' do
      @course_progress.completed_lessons << [@completed_lesson1]
      expect(@course_progress.next_lesson_id).to eq(@course.lessons.where(lesson_order: 2).first.id)
    end

    it 'should give the last lesson_id if course is complete' do
      @course_progress.completed_lessons << [@completed_lesson1, @completed_lesson2, @completed_lesson3]
      expect(@course_progress.next_lesson_id).to eq(@course.lessons.where(lesson_order: 3).first.id)
    end

    it 'should give the third lesson_id even if only course 2 is completed' do
      @course_progress.completed_lessons << [@completed_lesson2]
      expect(@course_progress.next_lesson_id).to eq(@course.lessons.where(lesson_order: 3).first.id)
    end

    it 'should throw an error if a course has no lessons' do
      @course.lessons.destroy_all
      expect { @course_progress.next_lesson_id }.to raise_error(StandardError)
    end

  end

  context '#last_completed_lesson_id_by_order' do

    before(:each) do
      @course = FactoryBot.create(:course)
      @lesson1 = FactoryBot.create(:lesson, lesson_order: 3)
      @lesson2 = FactoryBot.create(:lesson, lesson_order: 2)
      @lesson3 = FactoryBot.create(:lesson, lesson_order: 1)
      @course.lessons << [@lesson1, @lesson2, @lesson3]
      @course_progress = FactoryBot.create(:course_progress, course_id: @course.id)
      @completed_lesson1 = FactoryBot.create(:completed_lesson, lesson_id: @lesson3.id)
      @completed_lesson2 = FactoryBot.create(:completed_lesson, lesson_id: @lesson2.id)
    end

    it 'should return the id of the last completed lesson' do
      @course_progress.completed_lessons << [@completed_lesson1, @completed_lesson2]
      expect(@course_progress.last_completed_lesson_id_by_order).to eq(@lesson2.id)
    end

  end

end
