# frozen_string_literal: true

class CoursePresenter
  def initialize(course)
    @course = course
  end

  def as_json
    {
      seoPageTitle: @course.seo_page_title,
      seoMetaDescription: @course.meta_desc,
      summary: @course.summary,
      description: @course.description,
      contributor: @course.contributor,
      level: @course.level,
      notes: @course.notes,
      courseOrder: @course.course_order,
      surveyUrl: @course.survey_url,
      attCourse: @course.new_course
      # TODO: Category
    }
  end
end
