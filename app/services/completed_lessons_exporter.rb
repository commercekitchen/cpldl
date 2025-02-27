# frozen_string_literal: true

require 'csv'

class CompletedLessonsExporter
  def initialize(org)
    @org = org
    @primary_id_field = @org.deidentify_reports ? :uuid : @org.authentication_key_field
  end

  def to_csv
    lesson_completions = LessonCompletion
                          .includes(:lesson, course_progress: [:course, user: [:roles, :program, :profile, :school]])
                          .where(course_progresses: { users: { organization: @org } })
                          .order('users.email', 'users.library_card_number')
    
    CSV.generate do |csv|
      csv << column_headers

      lesson_completions.each do |lc|
        user = lc.course_progress.user
        next unless user.reportable_role?(@org)

        csv.add_row course_progress_row(user, lc)
      end
    end
  end

  private

  def column_headers
    headers = [User.human_attribute_name(@primary_id_field), 'Course', 'Lesson', 'Lesson Completed At', 'Course Completed At']
    headers << 'Program Name' if @org.accepts_programs?
    headers << 'Branch' if @org.branches?
    headers.concat(['School Type', 'School Name']) if @org.student_programs?
    headers
  end

  def course_progress_row(user, lesson_completion)
    course_progress = lesson_completion.course_progress
    values = [user.send(@primary_id_field), course_progress.course.title, lesson_completion.lesson.title, lesson_completion.created_at.strftime('%m-%d-%Y'), course_progress.completed_at&.strftime('%m-%d-%Y')]
    values << (user.program&.program_name || '') if @org.accepts_programs?
    values << (user.profile&.library_location&.name || '') if @org.branches?
    values.concat([user.school&.school_type&.titleize, user.school&.school_name]) if @org.student_programs?
    values
  end
end
