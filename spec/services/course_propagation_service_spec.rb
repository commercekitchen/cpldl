# frozen_string_literal: true

require 'rails_helper'

describe CoursePropagationService do
  let(:pla) { FactoryBot.create(:default_organization) }
  let(:course) { FactoryBot.create(:course_with_lessons, organization: pla) }
  let(:old_topic) { FactoryBot.create(:topic) }
  let!(:child_course) { FactoryBot.create(:course, parent: course, topics: [old_topic]) }

  describe '#propagate_course_changes' do
    describe 'model attribute changes' do
      let(:new_attributes) do
        {
          title: 'New Course Title',
          contributor: 'New Contributor',
          summary: 'New Summary',
          description: 'New Description',
          notes: 'New Notes',
          language: @spanish,
          format: 'M',
          level: 'Advanced',
          seo_page_title: 'New SEO Title',
          meta_desc: 'New Meta Desc'
        }
      end

      subject { described_class.new(course: course) }

      it 'should update child course info' do
        subject.propagate_course_changes(new_attributes)
        child_course.reload
        new_attributes.keys.each do |k|
          expect(child_course.send(k)).to eq(new_attributes[k])
        end
      end
    end

    describe 'topic changes' do
      let!(:topic) { FactoryBot.create(:topic) }

      before do
        course.update(topics: [topic])
      end

      subject { described_class.new(course: course) }

      it 'should add correct topic to child course' do
        subject.propagate_course_changes({})
        expect(child_course.reload.topics).to contain_exactly(topic)
      end
    end
  end
end
