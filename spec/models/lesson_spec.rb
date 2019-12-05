# frozen_string_literal: true

require 'rails_helper'

describe Lesson do

  let(:course) { FactoryBot.create(:course_with_lessons) }

  context 'validations' do
    let(:lesson) { FactoryBot.create(:lesson) }

    it 'initially it is valid' do
      expect(lesson).to be_valid
    end

    it 'is invalid without title' do
      lesson.title = nil
      expect(lesson).to_not be_valid
    end

    it 'is invalid with title that is too long' do
      lesson.title = 'a' * 91
      expect(lesson).to_not be_valid
    end

    it 'is invalid without summary' do
      lesson.summary = nil
      expect(lesson).to_not be_valid
    end

    it 'is invalid with summary that is too long' do
      lesson.summary = 'a' * 157
      expect(lesson).to_not be_valid
    end

    describe 'duration validations' do
      it 'is invalid with empty string duration' do
        lesson.duration = ''
        expect(lesson).to_not be_valid
      end

      it 'has correct error message with empty string duration' do
        lesson.update(duration: '')
        expect(lesson.errors.full_messages).to contain_exactly("Duration can't be blank")
      end

      it 'is invalid with nil duration' do
        lesson.duration = nil
        expect(lesson).to_not be_valid
      end

      it 'has correct error message for nil duration' do
        lesson.update(duration: nil)
        expect(lesson.errors.full_messages).to contain_exactly("Duration can't be blank")
      end

      it 'is invalid with non-numeric duration' do
        lesson.duration = 'foobar'
        expect(lesson).to_not be_valid
      end

      it 'has correct error message for non-numeric duration' do
        lesson.update(duration: 'foobar')
        expect(lesson.errors.full_messages).to contain_exactly('Duration is not a number')
      end

      it 'is invalid with non-integer duration' do
        lesson.duration = 1.6
        expect(lesson).to_not be_valid
      end

      it 'has correct error message for non-integer duration' do
        lesson.update(duration: 1.6)
        expect(lesson.errors.full_messages).to contain_exactly('Duration must be an integer')
      end

      it 'is invalid with <0 duration' do
        lesson.duration = -2
        expect(lesson).to_not be_valid
      end

      it 'has correct error message for <0 duration' do
        lesson.update(duration: -2)
        expect(lesson.errors.full_messages).to contain_exactly('Duration must be greater than 0')
      end
    end

    describe 'lesson order validations' do
      it 'is invalid with empty string lesson order' do
        lesson.lesson_order = ''
        expect(lesson).to_not be_valid
      end

      it 'has correct error message with empty string lesson order' do
        lesson.update(lesson_order: '')
        expect(lesson.errors.full_messages).to contain_exactly("Lesson order can't be blank")
      end

      it 'is invalid with nil lesson order' do
        lesson.lesson_order = nil
        expect(lesson).to_not be_valid
      end

      it 'has correct error message for nil lesson order' do
        lesson.update(lesson_order: nil)
        expect(lesson.errors.full_messages).to contain_exactly("Lesson order can't be blank")
      end

      it 'is invalid with non-numeric lesson order' do
        lesson.lesson_order = 'foobar'
        expect(lesson).to_not be_valid
      end

      it 'has correct error message for non-numeric lesson order' do
        lesson.update(lesson_order: 'foobar')
        expect(lesson.errors.full_messages).to contain_exactly('Lesson order is not a number')
      end

      it 'is invalid with non-integer lesson order' do
        lesson.lesson_order = 1.6
        expect(lesson).to_not be_valid
      end

      it 'has correct error message for non-integer lesson order' do
        lesson.update(lesson_order: 1.6)
        expect(lesson.errors.full_messages).to contain_exactly('Lesson order must be an integer')
      end

      it 'is invalid with <0 lesson order' do
        lesson.lesson_order = -2
        expect(lesson).to_not be_valid
      end

      it 'has correct error message for <0 lesson order' do
        lesson.update(lesson_order: -2)
        expect(lesson.errors.full_messages).to contain_exactly('Lesson order must be greater than 0')
      end
    end

    it 'is invalid seo page title that is too long' do
      lesson.seo_page_title = 'a' * 91
      expect(lesson).to_not be_valid
    end

    it 'is invalid with meta description that is too long' do
      lesson.meta_desc = 'a' * 157
      expect(lesson).to_not be_valid
    end

    describe 'publication status validations' do
      it 'is invalid with empty string publication status' do
        lesson.pub_status = ''
        expect(lesson).to_not be_valid
      end

      it 'has correct error message with empty string publication status' do
        lesson.update(pub_status: '')
        expect(lesson.errors.full_messages).to contain_exactly("Publication Status can't be blank")
      end

      it 'is invalid with nil publication status' do
        lesson.pub_status = nil
        expect(lesson).to_not be_valid
      end

      it 'has correct error message for nil publication status' do
        lesson.update(pub_status: nil)
        expect(lesson.errors.full_messages).to contain_exactly("Publication Status can't be blank")
      end

      it 'is invalid with invalid publication status' do
        lesson.pub_status = 'X'
        expect(lesson).to_not be_valid
      end

      it 'has correct error message for invalid publication status' do
        lesson.update(pub_status: 'X')
        expect(lesson.errors.full_messages).to contain_exactly('Publication Status X is not a valid status')
      end
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
