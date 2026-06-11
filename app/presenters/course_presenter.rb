# frozen_string_literal: true

class CoursePresenter
  include Rails.application.routes.url_helpers

  def initialize(course, user: nil)
    @course = course
    @user = user
  end

  def as_json
    {
      id: @course.slug,
      title: @course.title,
      seoPageTitle: @course.seo_page_title,
      seoMetaDescription: @course.meta_desc,
      summary: @course.summary,
      description: @course.description,
      contributor: @course.contributor,
      level: @course.level,
      notes: @course.notes,
      courseOrder: @course.course_order,
      surveyUrl: @course.survey_url,
      attCourse: @course.new_course,
      categoryName: @course.category&.name,
      categoryId: @course.category&.id,
      categoryOrder: @course.category&.category_order,
      attachments: attachments_payload,
      completed: completed?,
      lessonsCount: @course.lessons.count,
      lessonsCompletedCount: lessons_completed_count,
      totalDuration: @course.lessons.sum(:duration)
    }
  end

  private

  def completed?
    return false if @user.blank?

    @user.course_progresses.find_by(course_id: @course.id)&.completed_at.present?
  end

  def lessons_completed_count
    return 0 unless @user.is_a?(User)

    @course.lessons.completed_for_user(@user).count
  end

  def attachments_payload
    @course.attachments.order(:attachment_order).map do |attachment|
      {
        url: attachment_path(attachment),
        docType: attachment.doc_type,
        contentType: attachment_content_type(attachment),
        fileName: attachment_file_name(attachment)
      }
    end
  end

  def attachment_content_type(attachment)
    if attachment.document_file.attached?
      attachment.document_file.blob.content_type
    else
      attachment.document_content_type
    end
  end

  def attachment_file_name(attachment)
    if attachment.document_file.attached?
      attachment.document_file.filename.to_s
    else
      attachment.document_file_name.to_s
    end
  end
end
