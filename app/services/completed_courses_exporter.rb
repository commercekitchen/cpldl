# frozen_string_literal: true

require 'csv'

class CompletedCoursesExporter
  def initialize(org)
    @org = org
    @primary_id_field = @org.deidentify_reports ? :uuid : @org.authentication_key_field
  end

  def to_csv
    users = User.includes(:roles, :program, :profile, :school, course_progresses: :course)
                .where(organization_id: @org)
                .where_exists(:course_progresses, CourseProgress.arel_table[:completed_at].not_eq(nil))
                .order(:email, :library_card_number)

    CSV.generate do |csv|
      csv << column_headers

      users.each do |user|
        next unless user.reportable_role?(@org)

        user.course_progresses.each do |cp|
          next unless cp.complete?

          csv.add_row course_progress_row(user, cp)
        end
      end
    end
  end

  private

  def column_headers
    headers = [User.human_attribute_name(@primary_id_field), 'Course', 'Course Completed At']
    headers << 'Program Name' if @org.accepts_programs?
    headers << 'Branch' if @org.branches?
    headers.concat(['School Type', 'School Name']) if @org.student_programs?
    headers
  end

  def course_progress_row(user, course_progress)
    values = [
      user.public_send(@primary_id_field),
      course_progress.course.title,
      course_progress.completed_at.strftime('%m-%d-%Y')
    ]
    values << (user.program&.program_name || '') if @org.accepts_programs?
    values << (user.profile&.library_location&.name || '') if @org.branches?
    values.concat([user.school&.school_type&.titleize, user.school&.school_name]) if @org.student_programs?
    values
  end
end
