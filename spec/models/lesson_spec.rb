# frozen_string_literal: true

require 'rails_helper'

describe Lesson do

  let(:course) { FactoryBot.create(:course_with_lessons) }

  context 'validations' do

    before(:each) do
      @lesson = FactoryBot.create(:lesson)
    end

    it 'initially it is valid' do
      expect(@lesson).to be_valid
    end

  end

  context 'scopes' do

    context '.published' do

      it 'returns all published lessons' do
        expect(course.lessons.published).to contain_exactly(course.lessons.first, course.lessons.second, course.lessons.third)
      end

      it 'returns all published lessons' do
        course.lessons.second.update(pub_status: 'D')
        expect(course.lessons.published).to contain_exactly(course.lessons.first, course.lessons.third)
      end

      it 'returns all published lessons' do
        course.lessons.second.update(pub_status: 'A')
        expect(course.lessons.published).to contain_exactly(course.lessons.first, course.lessons.third)
      end

    end

    context '.copied_from_lesson' do

      let(:new_org) { FactoryBot.create(:organization) }
      let(:new_course) { FactoryBot.create(:course_with_lessons, organization: new_org) }
      let(:original_lesson) { course.lessons.first }
      let(:copied_lesson) { new_course.lessons.first }

      before(:each) do
        original_lesson.propagation_org_ids << new_org.id
        copied_lesson.update(parent_id: original_lesson.id)
      end

      it 'returns all copied lessons' do
        expect(Lesson.copied_from_lesson(original_lesson)).to include(copied_lesson)
      end

      it 'does not return non-copied lessons' do
        expect(Lesson.copied_from_lesson(original_lesson).count).to eq(1)
      end

    end

  end

  context '#published_lesson_order' do

    it 'returns the order of only published lessons' do
      course.lessons.second.update(pub_status: 'D')
      expect(course.lessons.first.published_lesson_order).to eq 1
      expect(course.lessons.second.published_lesson_order).to eq 0
      expect(course.lessons.third.published_lesson_order).to eq 2
    end

  end

  context '#propagates_org_ids' do
    it 'is empty by default' do
      expect(Lesson.new.propagation_org_ids).to eq([])
    end

    it 'can be updated' do
      lesson = Lesson.new
      lesson.propagation_org_ids = [1]
      expect(lesson.propagation_org_ids).to eq([1])
    end
  end
end
