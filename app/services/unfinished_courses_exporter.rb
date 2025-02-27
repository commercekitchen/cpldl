# frozen_string_literal: true

require 'csv'

class UnfinishedCoursesExporter

  def initialize(org, start_date: nil, end_date: nil)
    @start_date = start_date || Time.at(0)
    @end_date = end_date || Time.zone.now
    @org = org
    @primary_id_field = @org.deidentify_reports ? :uuid : @org.authentication_key_field
  end

  def to_csv
    course_progresses = CourseProgress
                          .includes(:course, user: [:roles, :program, :profile, :school])
                          .where(completed_at: nil, users: { organization: @org })
                          .where(created_at: @start_date..@end_date)
                          .order('users.email', 'users.library_card_number', 'users.phone_number', 'courses.title')
    
    CSV.generate do |csv|
      csv << column_headers

      course_progresses.each do |cp|
        next unless cp.user.reportable_role?(@org)

        csv.add_row course_progress_row(cp)
      end
    end
  end

  private

  def column_headers
    headers = [User.human_attribute_name(@primary_id_field), 'Course', 'Course Started At']
    headers << 'Program Name' if @org.accepts_programs?
    headers << 'Branch' if @org.branches?
    headers.concat(['School Type', 'School Name']) if @org.student_programs?
    headers
  end

  def course_progress_row(course_progress)
    user = course_progress.user
    values = [user.send(@primary_id_field), course_progress.course.title, course_progress.created_at.strftime('%m-%d-%Y')]
    values << (user.program&.program_name || '') if @org.accepts_programs?
    values << (user.profile&.library_location&.name || '') if @org.branches?
    values.concat([user.school&.school_type&.titleize, user.school&.school_name]) if @org.student_programs?
    values
  end
end
