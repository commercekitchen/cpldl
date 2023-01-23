# frozen_string_literal: true

require 'csv'

class CompletedCoursesExporter

  def initialize(org)
    @org = org
    @primary_id_field = @org.authentication_key_field
  end

  def to_csv
    users = User.includes(:roles).where(organization_id: @org).order(:email, :library_card_number)
    CSV.generate do |csv|
      csv << column_headers

      users.each do |user|
        next unless user.reportable_role?(@org)

        user.course_progresses.each do |cp|
          next unless cp.complete?

          program_name = user.program.present? ? user.program.program_name : ''
          values = [user.send(@primary_id_field), program_name, cp.course.title, cp.completed_at.strftime('%m-%d-%Y'), user.profile&.library_location&.name]
          values.concat([user.school&.school_type&.titleize, user.school&.school_name]) if school_program_org?
          csv.add_row values
        end
      end
    end
  end

  private

  def column_headers
    headers = [User.human_attribute_name(@primary_id_field), 'Program Name', 'Course', 'Course Completed At', 'Branch']
    headers.concat(['School Type', 'School Name']) if school_program_org?
    headers
  end

  def school_program_org?
    @school_program_org ||= @org.student_programs?
  end

end
