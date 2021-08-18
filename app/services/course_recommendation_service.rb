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
    (desktop_courses + mobile_courses + topic_courses) & org_courses
  end

  def desktop_courses
    response = @responses['set_one']
    core_courses.published.where(format: 'D', level: level_string(response))
  end

  def mobile_courses
    response = @responses['set_two']
    core_courses.published.where(format: 'M', level: level_string(response))
  end

  def topic_courses
    response = @responses['set_three']
    Course.published.topic_search(topics[response.to_i])
  end

  def topics
    {
      1 => 'Job Search',
      2 => 'Education: Child',
      3 => 'Government',
      4 => 'Education: Adult',
      5 => 'Communication Social Media',
      6 => 'Security',
      7 => 'Software Apps',
      8 => 'Information Searching'
    }
  end

  def level_string(level)
    case level
    when '1'
      'Beginner'
    when '2'
      'Intermediate'
    end
  end

  def language
    language_string = I18n.locale == :es ? 'Spanish' : 'English'
    Language.find_by(name: language_string)
  end

  def org_courses
    @org_courses ||= Course.where(organization: @org).where(language_id: language.id)
  end

  def core_courses
    Course.topic_search('Core')
  end
end
