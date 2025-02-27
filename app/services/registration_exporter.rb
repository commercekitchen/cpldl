# frozen_string_literal: true

require 'csv'

class RegistrationExporter

  def initialize(org, start_date: nil, end_date: nil)
    @start_date = start_date || Time.at(0)
    @end_date = end_date || Time.zone.now
    @org = org
    @primary_id_field = @org.deidentify_reports ? :uuid : @org.authentication_key_field
  end

  def to_csv
    users = User.includes(:roles)
              .where(organization_id: @org)
              .where(created_at: @start_date..@end_date)
              .order(:email, :library_card_number)

    CSV.generate do |csv|
      csv << column_headers

      users.each do |user|
        next unless user.reportable_role?(@org)

        csv.add_row registration_row(user)
      end
    end
  end

  private

  def column_headers
    headers = [User.human_attribute_name(@primary_id_field), 'Registration Date']
    headers << 'Program Name' if @org.accepts_programs?
    headers.concat(['Branch Name', 'Zip']) if @org.branches?
    headers.concat(['School Type', 'School Name', 'Student ID(s)']) if @org.student_programs?
    headers
  end

  def registration_row(user)
    values = [user.send(@primary_id_field), user.created_at]
    values << (user.program&.program_name || '') if @org.accepts_programs?
    values.concat([(user.library_location_name || ''), (user.library_location_zipcode || '')]) if @org.branches?
    values.concat([user.school&.school_type&.titleize, user.school&.school_name, user.student_id]) if @org.student_programs?
    values
  end
end
