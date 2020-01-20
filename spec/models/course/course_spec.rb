# frozen_string_literal: true

require 'rails_helper'

describe Course do
  let(:course) { FactoryBot.create(:course) }

  describe '#topics_list' do
    let!(:topic) { FactoryBot.create(:topic, title: 'Existing Topic') }

    it 'assigns topics to a course' do
      topics = ['Topic 1', 'Topic2']
      expect do
        course.topics_list(topics)
      end.to change { course.topics.count }.by(2)
    end

    it 'returns a topic list as a string' do
      topics = ['Topic 1', 'Topic 2']
      course.topics_list(topics)
      expect(course.topics_str).to eq('Topic 1, Topic 2')
    end

    it 'skips blank topics when assigning to a course' do
      topics = ['Topic 1', 'Topic2', '']
      expect do
        course.topics_list(topics)
      end.to change { course.topics.count }.by(2)
    end

    it 'adds new topics to the list, if not previously there' do
      topics = ['Topic 1', 'Topic2', 'Existing Topic', '']
      expect do
        course.topics_list(topics)
      end.to change(Topic, :count).by(2)
    end

    it 'does not add nil topics' do
      topics = nil
      expect do
        course.topics_list(topics)
      end.to_not(change { course.topics.count })
    end

    it 'does not add topics from empty topics list' do
      topics = []
      expect do
        course.topics_list(topics)
      end.to_not(change { course.topics.count })
    end
  end

  describe '#lesson_after' do
    let(:course_with_lessons) { FactoryBot.create(:course_with_lessons) }
    let(:first_lesson) { course_with_lessons.lessons.first }
    let(:second_lesson) { course_with_lessons.lessons.second }
    let(:third_lesson) { course_with_lessons.lessons.third }

    it 'should return the first lesson id if called without an id' do
      expect(course_with_lessons.lesson_after).to eq(first_lesson)
    end

    it 'should return the second lesson id if called with the first lesson id' do
      expect(course_with_lessons.lesson_after(first_lesson)).to eq(second_lesson)
    end

    it 'should return next lesson id if lesson order is skipped' do
      third_lesson.update(lesson_order: 5)
      expect(course_with_lessons.lesson_after(second_lesson)).to eq(third_lesson)
    end

    it 'should return the last lesson id if called with the last lesson id' do
      expect(course_with_lessons.lesson_after(third_lesson)).to eq(third_lesson)
    end

    it 'should return the first lesson id if called with an invalid lesson id' do
      expect(course_with_lessons.lesson_after(123)).to eq(first_lesson)
    end

    it 'should skip unpublished lessons' do
      second_lesson.update(pub_status: 'D')
      expect(course_with_lessons.lesson_after(first_lesson)).to eq(third_lesson)
    end

    it 'should raise an error if called when there are no lessons' do
      expect { course.lesson_after }.to raise_error(StandardError)
    end
  end

  describe '#duration' do
    let(:lesson1) { FactoryBot.create(:lesson, title: '1', duration: 75) }
    let(:lesson2) { FactoryBot.create(:lesson, title: '2', duration: 150) }
    let(:lesson3) { FactoryBot.create(:lesson, title: '3', duration: 225) }
    let(:lesson4) { FactoryBot.create(:lesson, title: '4', duration: 90) }
    let(:lesson5) { FactoryBot.create(:lesson, title: '5', duration: 9) }

    it 'should return the sum of the lesson durations' do
      course.lessons << [lesson1, lesson2, lesson3]
      expect(course.duration).to eq('7 mins')
    end

    it 'should return the sum of the lesson durations' do
      course.lessons << [lesson4]
      expect(course.duration).to eq('1 min')
    end

    it 'should return the sum of the lesson durations' do
      course.lessons << [lesson5]
      expect(course.duration).to eq('0 mins')
    end

    it 'should return duration in format if one is passed' do
      course.lessons << [lesson1, lesson2, lesson3]
      expect(course.duration('minutes')).to eq('7 minutes')
    end

    it 'should not count draft lessons' do
      lesson1.update(pub_status: 'D')
      course.lessons << [lesson1, lesson2, lesson3]
      expect(course.duration).to eq '6 mins'
    end
  end

  describe '#published?' do
    let(:draft_course) { FactoryBot.create(:draft_course) }
    let(:archived_course) { FactoryBot.create(:archived_course) }

    it 'should return true if course is published' do
      expect(course.published?).to be_truthy
    end

    it 'should return false if course is in draft status' do
      expect(draft_course.published?).to be_falsey
    end

    it 'should return false if course is archived' do
      expect(archived_course.published?).to be_falsey
    end
  end
end
