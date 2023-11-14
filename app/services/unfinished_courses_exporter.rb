# frozen_string_literal: true

require 'csv'

class UnfinishedCoursesExporter

  def initialize(org)
    @org = org
    @primary_id_field = @org.deidentify_reports ? :uuid : @org.authentication_key_field
  end

  def to_csv
    users = User.includes(:roles).where(organization_id: @org).order(:email, :library_card_number, :phone_number)
    CSV.generate do |csv|
      csv << column_headers
      users.each do |user|
        next unless user.reportable_role?(@org)

        user.course_progresses.each do |cp|
          next if cp.complete?

          csv.add_row course_progress_row(cp)
        end
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
    values.concat([user.school&.school_type&.titleize, user.school&.school_name]) if school_program_org?
    values
  end
end
