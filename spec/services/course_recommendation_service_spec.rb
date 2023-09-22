# frozen_string_literal: true

require 'rails_helper'

describe CourseRecommendationService do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:core_topic) { create(:topic, title: 'Core') }
  let(:topic1) { create(:topic) }
  let(:topic2) { create(:topic) }
  let!(:topic1_course) { create(:course, language: @english, topics: [topic1], organization: organization) }
  let!(:topic2_course) { create(:course, language: @english, topics: [topic2], organization: organization) }
  let!(:other_org_course) { create(:course, language: @english, topics: [topic1]) }

  before(:each) do
    # Create core courses
    %w[M D].each do |format|
      %w[Beginner Intermediate].each do |level|
        create(:course, language: @english, format: format, level: level, topics: [core_topic], organization: organization)
        create(:course, language: @spanish, format: format, level: level, topics: [core_topic], organization: organization)

        # Draft Courses
        create(:course, language: @english, format: format, level: level, topics: [core_topic], organization: organization, pub_status: 'D')
        create(:course, language: @spanish, format: format, level: level, topics: [core_topic], organization: organization, pub_status: 'D')
      end
    end
  end

  describe 'add recommended courses' do
    let(:responses) do
      {
        'desktop_level' => 'Intermediate',
        'mobile_level' => 'Advanced',
        'topics' => [topic1.title, topic2.title]
      }
    end
    let(:service) { CourseRecommendationService.new(organization.id, responses) }
    let(:int_desktop_course) { create(:course, language: @english, format: 'D', level: 'Intermediate', topics: [core_topic], organization: organization) }

    it 'adds correct courses' do
      expect do
        service.add_recommended_courses(user.id)
      end.to change { user.reload.course_progresses.count }.from(0).to(3)

      int_desktop_course = Course.find_by(format: 'D', level: 'Intermediate', organization: organization)
      expect(user.course_progresses.map(&:course)).to contain_exactly(topic1_course, topic2_course, int_desktop_course)
    end
  end

  describe 'spanish language course' do
    let(:responses) do
      {
        'desktop_level' => 'Beginner',
        'mobile_level' => 'Intermediate',
        'topics' => []
      }
    end
    let(:service) { CourseRecommendationService.new(organization.id, responses) }

    before(:each) do
      I18n.locale = :es
    end

    it 'should create course progresses' do
      expect do
        service.add_recommended_courses(user.id)
      end.to change { user.reload.course_progresses.count }.by(2)
    end

    it 'should only create course progresses for spanish courses' do
      service.add_recommended_courses(user.id)
      expect(user.reload.course_progresses.map { |cp| cp.course.language_id }.uniq).to contain_exactly(@spanish.id)
    end
  end
end
