# frozen_string_literal: true

require 'csv'

module Exporters
  class NoCoursesReportExporter
    def initialize(org, start_date: nil, end_date: nil)
      @start_date = start_date || Time.at(0)
      @end_date = end_date || Time.zone.now
      @org = org
      @primary_id_field = @org.deidentify_reports ? :uuid : @org.authentication_key_field
    end

    def stream_csv
      Enumerator.new do |yielder|
        yielder << CSV.generate_line(column_headers)

        users.find_in_batches(batch_size: 1000) do |batch|
          batch.each do |user|
            values = [user.send(@primary_id_field), user.created_at]
            yielder << CSV.generate_line(values)
          end
        end
      end
    end

    private

    def users
      User.joins(:roles)
          .left_joins(:course_progresses)
          .where(organization_id: @org)
          .where(created_at: @start_date..@end_date)
          .where(course_progresses: { id: nil })
          .where('roles.name IN (?)', %w[user parent student])
          .order(:email, :library_card_number)
    end

    def column_headers
      [User.human_attribute_name(@primary_id_field), 'Registration Date']
    end
  end
end
