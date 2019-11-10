# frozen_string_literal: true

require 'rails_helper'

describe Course do
  context '#topics_list' do

    before(:each) do
      @course = FactoryBot.create(:course)
      @topic = FactoryBot.create(:topic, title: 'Existing Topic')
    end

    it 'assigns topics to a course' do
      topics = ['Topic 1', 'Topic2']
      @course.topics_list(topics)
      @course.reload
      expect(@course.topics.count).to eq(2)
    end

    it 'returns a topic list as a string' do
      topics = ['Topic 1', 'Topic 2']
      @course.topics_list(topics)
      @course.reload
      expect(@course.topics_str).to eq('Topic 1, Topic 2')
    end

    it 'skips blank topics when assigning to a course' do
      topics = ['Topic 1', 'Topic2', '']
      @course.topics_list(topics)
      @course.reload
      expect(@course.topics.count).to eq(2)
    end

    it 'adds new topics to the list, if not previously there' do
      topics = ['Topic 1', 'Topic2', 'Topic3', '']
      @course.topics_list(topics)
      expect(Topic.count).to eq(4) # The exising + the 3 non-empty topics.
    end

    it 'does nothing if the topics list is blank' do
      topics = nil
      @course.topics_list(topics)
      @course.reload
      expect(@course.topics.count).to eq(0)

      topics = []
      @course.topics_list(topics)
      @course.reload
      expect(@course.topics.count).to eq(0)
    end

  end

  context '#next_lesson_id (from old version of next_lesson_id)' do

    before :each do
      @course = FactoryBot.create(:course_with_lessons)
    end

    it 'should return the first lesson id if called without an id' do
      expect(@course.next_lesson_id).to be(@course.lessons.first.id)
    end

    it 'should return the second lesson id if called with the first lesson id' do
      expect(@course.next_lesson_id(@course.lessons.first.id)).to be(@course.lessons.second.id)
    end

    it 'should return the last lesson id if called with the last lesson id' do
      expect(@course.next_lesson_id(@course.lessons.last.id)).to be(@course.lessons.last.id)
    end

    it 'should return the first lesson id if called with an invalid lesson id' do
      expect(@course.next_lesson_id(123)).to be(@course.lessons.first.id)
    end

    it 'should raise an error if called when there are no lessons' do
      @course.lessons.destroy_all
      expect { @course.next_lesson_id }.to raise_error(StandardError)
    end

  end

  context '#next_lesson_id' do

    it 'should raise an error if there are no lessons' do
      expect do
        @course = FactoryBot.create(:course)
        @course.next_lesson_id(@course.lessons.first.id)
      end.to raise_error StandardError
    end

    it 'should return the id of the next lesson in order' do
      @course = FactoryBot.create(:course_with_lessons)
      expect(@course.next_lesson_id).to eq @course.lessons.first.id
      expect(@course.next_lesson_id(nil)).to eq @course.lessons.first.id
      expect(@course.next_lesson_id(@course.lessons.first.id)).to eq @course.lessons.second.id
      expect(@course.next_lesson_id(@course.lessons.second.id)).to eq @course.lessons.third.id
      expect(@course.next_lesson_id(@course.lessons.third.id)).to eq @course.lessons.third.id
    end

    it 'should return the next lesson id, even if the lessons are out of order' do
      @course = FactoryBot.create(:course_with_lessons)
      @course.lessons.third.update(lesson_order: 5)
      expect(@course.next_lesson_id(@course.lessons.first.id)).to eq @course.lessons.second.id
      expect(@course.next_lesson_id(@course.lessons.second.id)).to eq @course.lessons.third.id
      expect(@course.next_lesson_id(@course.lessons.third.id)).to eq @course.lessons.third.id
    end

    it 'should skip unpublished lessons' do
      @course = FactoryBot.create(:course_with_lessons)
      @course.lessons.second.update(pub_status: 'D')
      @course.lessons.third.update(lesson_order: 5)
      expect(@course.next_lesson_id(@course.lessons.first.id)).to eq @course.lessons.third.id
      expect(@course.next_lesson_id(@course.lessons.third.id)).to eq @course.lessons.third.id
    end

  end

  context '#duration' do

    before :each do
      @course = FactoryBot.create(:course)
      @lesson1 = FactoryBot.create(:lesson, title: '1', duration: 75)
      @lesson2 = FactoryBot.create(:lesson, title: '2', duration: 150)
      @lesson3 = FactoryBot.create(:lesson, title: '3', duration: 225)
      @lesson4 = FactoryBot.create(:lesson, title: '4', duration: 90)
      @lesson5 = FactoryBot.create(:lesson, title: '5', duration: 9)
    end

    it 'should return the sum of the lesson durations' do
      @course.lessons << [@lesson1, @lesson2, @lesson3]
      expect(@course.duration).to eq('7 mins')
    end

    it 'should return the sum of the lesson durations' do
      @course.lessons << [@lesson4]
      expect(@course.duration).to eq('1 min')
    end

    it 'should return the sum of the lesson durations' do
      @course.lessons << [@lesson5]
      expect(@course.duration).to eq('0 mins')
    end

    it 'should return duration in format if one is passed' do
      @course.lessons << [@lesson1, @lesson2, @lesson3]
      expect(@course.duration('minutes')).to eq('7 minutes')
    end

    it 'should not count draft lessons' do
      @course = FactoryBot.create(:course_with_lessons)
      @course.lessons.first.update(pub_status: 'D')
      expect(@course.duration).to eq '3 mins' # 90 * 2 = 180 / 60 = 3 mins
    end

  end

end
