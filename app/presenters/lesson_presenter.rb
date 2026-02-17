# frozen_string_literal: true

class LessonPresenter
  def initialize(lesson, user: nil)
    @lesson = lesson
    @user = user
    @course = @lesson.course
  end

  def as_json
    {
      id: @lesson.slug,
      courseId: @course.id,
      title: @lesson.title,
      summary: @lesson.summary,
      duration: @lesson.duration,
      updated_at: @lesson.updated_at&.iso8601,
      seoPageTitle: @lesson.seo_page_title,
      seoMetaDescription: @lesson.meta_desc,
      isAssessment: @lesson.is_assessment,
      lessonOrder: @lesson.lesson_order,
      level: @course.level,
      course: CoursePresenter.new(@course).as_json,
      completed: completed?,
      category: @course.category&.name,
      topics: @course.topics.map(&:title),
      storylinePath: storyline_path,
      storylineUrl: storyline_url
    }
  end

  private

  def completed?
    return false unless @user

    user.completed_lesson_ids(@course).include?(@lesson)
  end

  def storyline_path
    @lesson.storyline_entry_path
  end

  def storyline_url
    storyline_path && "#{Rails.configuration.cloudfront_url}#{storyline_path}"
  end
end
