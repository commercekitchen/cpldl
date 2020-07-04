# frozen_string_literal: true

require 'csv'

class RegistrationExporter

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

        program_name = user.program.present? ? user.program.program_name : ''
        values = [user.send(@primary_id_field), program_name, user.created_at]
        values.concat([user.library_location_name, user.library_location_zipcode]) if @org.branches?
        values.concat([user.school.school_type.titleize, user.school.school_name, user.student_id]) if school_programs?
        csv.add_row values
      end
    end
  end

  private

  def column_headers
    headers = [User.human_attribute_name(@primary_id_field), 'Program Name', 'Registration Date']
    headers.concat(['Branch Name', 'Zip']) if @org.branches?
    headers.concat(['School Type', 'School Name', 'Student ID(s)']) if school_programs?
    headers
  end

  def school_programs?
    @school_programs ||= @org.student_programs?
  end

end
