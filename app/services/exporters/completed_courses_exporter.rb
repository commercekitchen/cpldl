# frozen_string_literal: true

require 'csv'

module Exporters
  class CompletedCoursesExporter
    def initialize(org, start_date: nil, end_date: nil)
      @start_date = start_date || Time.at(0)
      @end_date = end_date || Time.zone.now
      @org = org
      @primary_id_field = @org.deidentify_reports ? :uuid : @org.authentication_key_field
    end

    def stream_csv
      Enumerator.new do |yielder|
        yielder << CSV.generate_line(column_headers)

        course_completions.find_in_batches(batch_size: 1000) do |batch|
          batch.each do |cc|
            yielder << CSV.generate_line(course_progress_row(cc.user, cc))
          end
        end
      end
    end

    private

    def course_completions
      included_associations = [:roles]

      included_associations << :program if @org.accepts_programs?
      included_associations << :profile if @org.branches?
      included_associations << :school if @org.student_programs?

      CourseProgress
        .includes(:course, user: included_associations)
        .where.not(completed_at: nil)
        .where(completed_at: @start_date..@end_date)
        .where(users: { organization: @org })
        .where('roles.name IN (?)', %w[user parent student])
        .order('users.email', 'users.library_card_number')
    end

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
      values << (user.library_location_name || '') if @org.branches?
      values.concat([user.school&.school_type&.titleize, user.school&.school_name]) if @org.student_programs?
      values
    end
  end
end
