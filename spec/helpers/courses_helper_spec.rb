# frozen_string_literal: true

require 'rails_helper'

describe CoursesHelper do
  let(:user) { FactoryBot.create(:user) }
  let(:organization) { user.organization }
  let!(:course) { FactoryBot.create(:course, organization: organization) }

  describe '#pub_status_str' do
    it 'returns the full name for a given status' do
      course.pub_status = 'D'
      expect(helper.pub_status_str(course)).to eq('Draft')
      course.pub_status = 'P'
      expect(helper.pub_status_str(course)).to eq('Published')
      course.pub_status = 'T'
      expect(helper.pub_status_str(course)).to eq('Trashed')
    end
  end

  describe '#percent_complete' do
    let!(:course2) { FactoryBot.create(:course, title: 'Course 2') }
    let!(:course_progress) { FactoryBot.create(:course_progress, user: user, course: course) }

    before(:each) do
      sign_in user
    end

    it "returns an empty string if the user isn't logged in" do
      sign_out user
      expect(helper.percent_complete(course)).to eq('')
    end

    it 'returns an empty string if the user doesnt have a course progress for the course' do
      expect(helper.percent_complete(course2)).to eq('0% Complete')
    end

    it 'returns the course progress' do
      expect(helper.percent_complete(course)).to eq('0% Complete')
    end

    it 'returns the course progress without a user' do
      expect(helper.percent_complete_without_user(course, 1)).to eq(0)
    end
  end

  describe '#courses_completed' do
    context 'no authenticated user' do
      it 'should return empty array for completed courses if no session completions' do
        expect(helper.courses_completed).to eq([])
      end
    end

    context 'with authenticated user' do
      let!(:completion) { FactoryBot.create(:course_progress, user: user, course: course, completed_at: Time.zone.now) }
      let!(:unfinished_course) { FactoryBot.create(:course_progress, user: user, course: course) }

      before do
        sign_in user
      end

      it 'should return completed courses for user' do
        expect(helper.courses_completed).to contain_exactly(course.id)
      end
    end
  end

  describe '#categorized_courses' do
    let(:category) { FactoryBot.create(:category, organization: organization) }
    let(:disabled_category) { FactoryBot.create(:category, :disabled, organization: organization) }
    let!(:course_with_category) { FactoryBot.create(:course, category: category, organization: organization) }
    let!(:uncategorized_course) { FactoryBot.create(:course, organization: organization) }
    let!(:course_with_disabled_category) { FactoryBot.create(:course, category: disabled_category, organization: organization) }

    let(:result) { helper.categorized_courses(organization.courses) }

    before do
      @request.host = "#{organization.subdomain}.test.host"
      sign_in user
    end

    it 'should return courses by category' do
      expect(result[category.name]).to contain_exactly(course_with_category)
    end

    it 'should return uncategorized courses' do
      expect(result['Uncategorized']).to include(uncategorized_course)
    end

    it 'should return courses with disabled category as uncategorized' do
      expect(result['Uncategorized']).to include(course_with_disabled_category)
    end
  end

  describe '#start_or_resume_course_link' do
    let(:course) { FactoryBot.create(:course_with_lessons, organization: organization) }

    before do
      @request.host = "#{organization.subdomain}.test.host"
      sign_in user
    end

    it 'should render link to first lesson with no course progress' do
      expected_path = course_lesson_path(course, course.lessons.first)
      expect(helper.start_or_resume_course_link(course)).to include(expected_path)
    end

    it 'should render link to latest incomplete lesson if course progress exists' do
      course_progress = FactoryBot.create(:course_progress, course: course, user: user)
      FactoryBot.create(:lesson_completion, course_progress: course_progress, lesson: course.lessons.first)
      expected_path = course_lesson_path(course, course.lessons.second)
      expect(helper.start_or_resume_course_link(course)).to include(expected_path)
    end

    it 'should include preview param if given' do
      expected_path = course_lesson_path(course, course.lessons.first, preview: true)
      expect(helper.start_or_resume_course_link(course, true)).to include(expected_path)
    end
  end
end
