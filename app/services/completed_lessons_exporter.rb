# frozen_string_literal: true

require 'csv'

class CompletedLessonsExporter
  def initialize(org, start_date: nil, end_date: nil)
    @start_date = start_date || Time.at(0)
    @end_date = end_date || Time.zone.now
    @org = org
    @primary_id_field = @org.deidentify_reports ? :uuid : @org.authentication_key_field
  end

  def stream_csv
    Enumerator.new do |yielder|
      yielder << CSV.generate_line(column_headers)


      lesson_completions.find_in_batches(batch_size: 1000) do |batch|
        batch.each do |lc|
          user = lc.course_progress.user
          next unless user.reportable_role?(@org)

          yielder << CSV.generate_line(course_progress_row(user, lc))
        end
      end
    end
  end

  private

  def lesson_completions
    LessonCompletion
      .includes(:lesson, course_progress: [:course, user: [:roles, :program, :profile, :school]])
      .where(course_progresses: { users: { organization: @org } })
      .where(created_at: @start_date..@end_date)
      .order('users.email', 'users.library_card_number', 'lessons.lesson_order')
  end

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
