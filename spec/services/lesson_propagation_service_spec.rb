# frozen_string_literal: true

require 'rails_helper'

describe LessonPropagationService do
  let(:parent_course) { FactoryBot.create(:course_with_lessons) }
  let(:child_course) { FactoryBot.create(:course, parent: parent_course) }

  let(:lesson) { parent_course.lessons.first }

  subject { described_class.new(lesson: lesson) }

  describe '#add_to_course!' do
    it 'should create a new lesson' do
      expect do
        subject.add_to_course!(child_course)
      end.to change { child_course.lessons.count }.by(1)
    end
  end

  describe '#update_children!' do
    let(:child_lesson) { FactoryBot.create(:lesson_without_story, parent: lesson) }
    let(:new_story_line) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'BasicSearch1.zip'), 'application/zip') }

    it 'should propagate lesson title' do
      original_title = child_lesson.title

      expect do
        subject.update_children!
      end.to change { child_lesson.reload.title }.from(original_title).to(lesson.title)
    end

    it 'should propagate assessment' do
      lesson.update(is_assessment: true)

      expect do
        subject.update_children!
      end.to change { child_lesson.reload.is_assessment? }.from(false).to(true)
    end

    it 'should not change lesson course' do
      expect do
        subject.update_children!
      end.to_not(change { child_lesson.reload.course_id })
    end

    it 'should preserve lesson parent' do
      expect do
        subject.update_children!
      end.to_not(change { child_lesson.reload.parent_id })
    end

    it 'should update child sort order' do
      lesson.update(lesson_order: 4)

      expect do
        subject.update_children!
      end.to(change { child_lesson.reload.lesson_order })
    end

    describe 'story_line propagation' do
      before do
        lesson.update!(story_line: new_story_line)
      end

      it 'should not propagate story_line' do
        expect do
          subject.update_children!
        end.to_not(change { child_lesson.reload.story_line })
      end

      it 'should not propagate story_line filename' do
        expect do
          subject.update_children!
        end.to_not(change { child_lesson.reload.story_line_file_name })
      end

      it 'should not propagate story_line file size' do
        expect do
          subject.update_children!
        end.to_not(change { child_lesson.reload.story_line_file_size })
      end
    end
  end
end
