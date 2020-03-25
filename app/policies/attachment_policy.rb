# frozen_string_literal: true

class AttachmentPolicy < AdminOnlyPolicy

  def show?
    course_to_authorize = child_course || record.course

    CoursePolicy.new(user, course_to_authorize).show?
  end

  private

  def organization
    record.course.organization
  end

  def child_courses
    Course.copied_from_course(record.course)
  end

  def child_course
    child_courses.where(organization_id: user.organization.id).first
  end

  def attachment_current_course
    child_course || record.course
  end
end
