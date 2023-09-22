# frozen_string_literal: true

class CourseRecommendationService

  def initialize(org_id, responses)
    @org = Organization.find(org_id)
    @responses = responses
  end

  def add_recommended_courses(user_id)
    @user = User.find(user_id)

    course_collection.each do |course|
      course_progress = @user.course_progresses.where(course_id: course.id).first_or_create
      course_progress.tracked = true
      course_progress.save
    end
  end

  private

  def course_collection
    core_desktop_courses.or(core_mobile_courses).or(topic_courses)
  end

  def core_desktop_courses
    level = @responses['desktop_level']
    return available_courses.none if level == 'Advanced'
    core_courses.where(format: 'D', level: level)
  end

  def core_mobile_courses
    level = @responses['mobile_level']
    return available_courses.none if level == 'Advanced'
    core_courses.where(format: 'M', level: level)
  end

  def topic_courses
    topics = @responses['topics']
    available_courses.where('topics.title IN (?)', topics)
  end

  def core_courses
    available_courses.where(topics: { title: 'Core' })
  end

  def available_courses
    Course
      .joins(:topics)
      .where(organization: @org)
      .where(language_id: language.id)
      .where(pub_status: 'P')
  end

  def language
    language_string = I18n.locale == :es ? 'Spanish' : 'English'
    Language.find_by(name: language_string)
  end
end
