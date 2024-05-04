# frozen_string_literal: true

require 'rails_helper'

describe Course do
  let(:course) { FactoryBot.create(:course) }
  let(:org) { course.organization }
  let(:pla) { FactoryBot.create(:default_organization) }

  describe 'scopes' do
    describe '#pla' do
      let!(:pla_course) { FactoryBot.create(:course, organization: pla) }
      let!(:non_pla_course) { FactoryBot.create(:course) }

      it 'should return www courses only' do
        expect(Course.pla).to contain_exactly(pla_course)
      end
    end

    describe '#visible_to_users' do
      let(:organization) { FactoryBot.create(:organization) }
      let!(:published_course) { FactoryBot.create(:course, organization: organization) }
      let!(:coming_soon_course) { FactoryBot.create(:coming_soon_course, organization: organization) }

      it 'should return all published and coming soon courses' do
        expect(Course.visible_to_users).to contain_exactly(published_course, coming_soon_course)
      end
    end
  end

  describe 'category' do
    it 'should create org category based on category name' do
      expect do
        course.update(category_name: 'New Category')
      end.to change { org.categories.count }.by(1)
    end

    describe 'existing category' do
      let!(:category) { FactoryBot.create(:category, organization: org, name: 'Existing Category') }

      it 'should not create a new category' do
        expect do
          course.update(category_name: category.name)
        end.to_not(change { org.categories.count })
      end

      it 'should add course to existing category' do
        expect do
          course.update(category_name: category.name)
        end.to change { category.courses.count }.by(1)
      end

      it 'should add course to existing category in case-insensitive manner' do
        expect do
          course.update(category_name: 'eXisting categorY')
        end.to change { category.courses.count }.by(1)
      end
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

    it 'should raise an error if called when there are no lessons' do
      expect { course.lesson_after }.to raise_error(StandardError)
    end
  end

  describe '#duration' do
    let!(:lesson1) { FactoryBot.create(:lesson, course: course, title: '1', duration: 75) }
    let!(:lesson2) { FactoryBot.create(:lesson, course: course, title: '2', duration: 150) }
    let!(:lesson3) { FactoryBot.create(:lesson, course: course, title: '3', duration: 225) }
    let!(:lesson4) { FactoryBot.create(:lesson, title: '4', duration: 90) }
    let!(:lesson5) { FactoryBot.create(:lesson, title: '5', duration: 9) }

    it 'should return the sum of the lesson durations' do
      expect(course.duration).to eq('7 mins')
    end

    it 'should return the sum of the lesson durations' do
      expect(lesson4.course.duration).to eq('1 min')
    end

    it 'should return the sum of the lesson durations' do
      expect(lesson5.course.duration).to eq('0 mins')
    end

    it 'should return duration in format if one is passed' do
      expect(course.duration('minutes')).to eq('7 minutes')
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

  describe '#imported_course?' do
    let(:pla_course) { FactoryBot.create(:course, organization: pla) }
    let(:child_course) { FactoryBot.create(:course, parent: pla_course) }

    it 'returns false if course has no parent' do
      expect(pla_course.imported_course?).to eq(false)
    end

    it 'returns true if course has a parent' do
      expect(child_course.imported_course?).to eq(true)
    end
  end

  describe 'attachments' do
    let(:pla_course) { FactoryBot.create(:course, organization: pla) }
    let(:child_course) { FactoryBot.create(:course, parent: pla_course) }
    let!(:additional_resource_attachment) { FactoryBot.create(:attachment, doc_type: 'additional-resource', course: pla_course, attachment_order: 2) }
    let!(:text_copy_attachment) { FactoryBot.create(:attachment, doc_type: 'text-copy', course: pla_course, attachment_order: 2) }
    let!(:subsite_additional_resource_attachment) { FactoryBot.create(:attachment, doc_type: 'additional-resource', course: child_course) }

    context 'parent course' do
      it 'returns correct additional resources sorted by attachment_order' do
        attachment2 = FactoryBot.create(:attachment, doc_type: 'additional-resource', course: pla_course, attachment_order: 1)
        expect(pla_course.additional_resource_attachments).to eq([attachment2, additional_resource_attachment])
      end

      it 'returns correct text copy attachments sorted by attachment_order' do
        attachment2 = FactoryBot.create(:attachment, doc_type: 'text-copy', course: pla_course, attachment_order: 1)
        expect(pla_course.text_copy_attachments).to eq([attachment2, text_copy_attachment])
      end
    end

    context 'child course' do
      it 'returns subsite specific additional_resource_attachments' do
        expect(child_course.additional_resource_attachments).to contain_exactly(subsite_additional_resource_attachment)
      end

      it 'returns parent text copies' do
        expect(child_course.text_copy_attachments).to contain_exactly(text_copy_attachment)
      end
    end
  end

  describe '#pub_status_options' do
    it 'should contain array of publication status options' do
      expected_options_array = [%w[Draft D], %w[Published P], %w[Archived A], ['Coming Soon', 'C']]
      expect(Course.pub_status_options).to eq(expected_options_array)
    end
  end
end
