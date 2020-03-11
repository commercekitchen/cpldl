# frozen_string_literal: true

require 'rails_helper'

describe CoursePropagationService do
  let(:pla) { FactoryBot.create(:default_organization) }
  let(:course) { FactoryBot.create(:course_with_lessons, organization: pla) }
  let!(:child_course) { FactoryBot.create(:course, parent: course) }

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
    course.update(new_attributes)
    subject.propagate_course_changes
    child_course.reload
    new_attributes.keys.each do |k|
      expect(child_course.send(k)).to eq(new_attributes[k])
    end
  end

  it 'should update child course attachments' do
  end

  it 'should propagate topic changes' do
  end

  it 'should not change child course category' do
  end

  it 'should not change child course access level' do
  end
end
