# frozen_string_literal: true

require 'rails_helper'
require 'csv'

describe CompletedLessonsExporter do
  describe 'standard organization report' do
    let(:organization) { FactoryBot.create(:organization) }
    let(:course) { create(:course_with_lessons, organization: organization) }

    let(:course_complete_user) { FactoryBot.create(:user, organization: organization) }
    let!(:course_completion) { FactoryBot.create(:course_progress, course: course,  user: course_complete_user, completed_at: Time.zone.now) }

    let(:course_incomplete_user) { FactoryBot.create(:user, organization: organization) }
    let!(:course_progress) { FactoryBot.create(:course_progress, course: course, user: course_incomplete_user) }

    let(:exporter) { described_class.new(organization) }
    let(:report) { CSV.parse(exporter.to_csv, headers: true) }

    before do
      course.lessons.each do |lesson|
        FactoryBot.create(:lesson_completion, lesson: lesson, course_progress: course_completion)
      end

      FactoryBot.create(:lesson_completion, lesson: course.lessons.first, course_progress: course_progress)
    end

    context 'email report' do
      it 'has correct headers' do
        expect(report.headers).to eq(['Email', 'Course', 'Lesson', 'Lesson Completed At', 'Course Completed At'])
      end

      it 'contains correct data' do
        row = report.first
        expect(row['Email']).to eq(course_complete_user.email)
        expect(row['Course']).to eq(course.title)
        expect(row['Lesson']).to eq(course.lessons.first.title)
        expect(row['Lesson Completed At']).to be_a(String)
        expect(row['Course Completed At']).not_to be_nil
      end
    end

    context 'deidentified report' do
      before do
        organization.update(deidentify_reports: true)
      end

      it 'contains correct headers' do
        expect(report.headers).to eq(['Uuid', 'Course', 'Lesson', 'Lesson Completed At', 'Course Completed At'])
      end

      it 'contains correct data' do
        row = report.first
        expect(row['Uuid']).to eq(course_complete_user.uuid)
        expect(row['Course']).to eq(course.title)
        expect(row['Lesson']).to eq(course.lessons.first.title)
        expect(row['Lesson Completed At']).to be_a(String)
        expect(row['Course Completed At']).not_to be_nil
      end
    end
  end
end
