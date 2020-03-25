# frozen_string_literal: true

require 'rails_helper'

describe CourseImportService do
  let(:pla) { FactoryBot.create(:default_organization) }
  let(:topic) { FactoryBot.create(:topic) }
  let(:category) { FactoryBot.create(:category, organization: pla) }
  let(:pla_course) { FactoryBot.create(:course_with_lessons, organization: pla, topics: [topic], category: category) }

  let(:document) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'testfile.pdf'), 'application/pdf') }
  let!(:attachment) { FactoryBot.create(:attachment, document: document, course: pla_course) }

  let(:subsite) { FactoryBot.create(:organization) }

  subject { described_class.new(organization: subsite, course_id: pla_course.id) }

  it 'should create a new course record for subsite' do
    expect do
      subject.import!
    end.to change { subsite.courses.count }.by(1)
  end

  it 'should create new course as a child of original course' do
    expect do
      subject.import!
    end.to change { Course.copied_from_course(pla_course).count }.by(1)
  end

  it 'should import course in draft status' do
    expect do
      subject.import!
    end.to change { Course.where(pub_status: 'D').count }.by(1)
  end

  it 'should create new category on organization' do
    expect do
      subject.import!
    end.to change { subsite.categories.count }.by(1)
  end

  it 'should copy lessons into organization' do
    expect do
      subject.import!
    end.to change { subsite.lessons.count }.by(3)
  end

  it 'should not copy attachments' do
    expect do
      subject.import!
    end.to_not change(Attachment, :count)
  end

  it 'should create new course topic' do
    expect do
      subject.import!
    end.to change(CourseTopic, :count).by(1)
  end
end