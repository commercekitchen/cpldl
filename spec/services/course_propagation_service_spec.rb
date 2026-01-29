# frozen_string_literal: true

require 'rails_helper'

describe CoursePropagationService do
  let(:pla) { FactoryBot.create(:default_organization) }
  let(:course) { FactoryBot.create(:course_with_lessons, organization: pla) }
  let(:old_topic) { FactoryBot.create(:topic) }
  let!(:child_course) { FactoryBot.create(:course, parent: course, topics: [old_topic]) }

  describe '#propagate_course_changes' do
    describe 'model attribute changes' do
      let(:updated_course_source) { FactoryBot.create(:course) }
      let(:updated_attrs) do
        updated_course_source.attributes.symbolize_keys.slice(*CoursePropagationService::PROPAGATED_ATTRS)
      end

      before do
        course.update!(updated_attrs)
      end

      subject { described_class.new(course: course) }

      it 'should update child course info' do
        subject.propagate_course_changes!
        child_course.reload
        CoursePropagationService::PROPAGATED_ATTRS.each do |attr|
          expect(child_course.public_send(attr)).to eq(course.public_send(attr))
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
        subject.propagate_course_changes!
        expect(child_course.reload.topics).to contain_exactly(topic)
      end
    end

    describe 'error reporting' do
      subject { described_class.new(course: course) }

      it 'returns error details when propagation fails' do
        course.update_columns(format: 'Z')

        failures = subject.propagate_course_changes!

        expect(failures).to include(
          hash_including(child_id: child_course.id, error: a_string_including('Format'))
        )
      end
    end
  end
end
