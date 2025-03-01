# frozen_string_literal: true

class CompletionReportService
  def initialize(organization:)
    @organization = organization
  end

  def generate_completion_report(group_by:, start_date: nil, end_date: nil)
    @start_date = start_date || Time.at(0)
    @end_date = end_date || Time.zone.now
    Export.to_csv_for_completion_report(self.send("report_data_by_#{group_by}"), @organization)
  end

  private

  def subsite_users
    @subsite_users ||= @organization.users.with_role(:user, @organization).where(created_at: @start_date..@end_date)
  end

  def report_data_by_partner
    data = { version: 'partner' }

    partner_counts = subsite_users.includes(:partner)
                                  .group('partners.id')
                                  .pluck('partners.name', 'partners.id', Arel.sql('count(users)'))

    partner_counts.each do |partner_name, partner_id, user_count|
      key = partner_name || 'No Partner Selected'
      completions_data = partner_completions(partner_id)
      data[key] = { sign_ups: user_count, completions: completions_data }
    end

    data
  end

  def partner_completions(partner_id)
    CourseProgress.completed
                  .includes(:course, :user)
                  .where(users: { partner_id: partner_id, id: subsite_users.map(&:id) })
                  .where(completed_at: @start_date..@end_date)
                  .group('courses.title')
                  .pluck('courses.title', Arel.sql('count(course_progresses)'))
  end

  def report_data_by_zip_code
    grouped = { version: 'zip_code' }
    course_progs = CourseProgress.completed_with_profile.where(completed_at: @start_date..@end_date)
    zip_codes = course_progs.merge(subsite_users).pluck(:zip_code).uniq

    zip_codes.each do |z|
      progress_by_zip = course_progs.merge(subsite_users.joins(:profile).where(profiles: { zip_code: z }))
      progresses = {}

      progress_by_zip.each do |p|
        unless progresses.key?(p.course.title)
          progresses.merge!(p.course.title => progress_by_zip.where(course_id: p.course.id).count)
        end
      end

      users_by_zip = subsite_users.joins(:profile).where(profiles: { zip_code: z }).count

      data = { sign_ups: users_by_zip, completions: progresses }

      grouped.merge!(z => data)
    end

    grouped
  end

  def report_data_by_library
    grouped = { version: 'library' }
    course_progs = CourseProgress.completed_with_profile.where(completed_at: @start_date..@end_date)
    lib_ids = course_progs.merge(subsite_users).pluck(:library_location_id).uniq

    lib_ids.each do |l_id|
      progress_by_location = course_progs.merge(subsite_users.joins(:profile).where(profiles: { library_location_id: l_id }))
      progresses = {}

      progress_by_location.each do |p|
        unless progresses.key?(p.course.title)
          progresses.merge!(p.course.title => progress_by_location.where(course_id: p.course.id).count)
        end
      end

      users_by_lib = subsite_users.joins(:profile).where(profiles: { library_location_id: l_id }).count

      data = { sign_ups: users_by_lib, completions: progresses }

      grouped.merge!(l_id => data)
    end

    grouped
  end

  def report_data_by_survey_responses
    grouped = { version: 'survey_responses' }
    course_progs = CourseProgress.completed_with_profile.where(completed_at: @start_date..@end_date)
    quiz_response_combinations = course_progs.merge(subsite_users).map { |prog| prog.user.quiz_responses_object }.compact.uniq

    quiz_response_combinations.each do |responses_hash|
      users_with_responses = subsite_users.where('users.quiz_responses_object = ?', responses_hash.to_yaml)
      progresses_by_quiz_responses = course_progs.merge(users_with_responses)

      progresses = {}

      progresses_by_quiz_responses.each do |p|
        unless progresses.key?(p.course.title)
          progresses.merge!(p.course.title => progresses_by_quiz_responses.where(course_id: p.course.id).count)
        end
      end

      data = { responses: users_with_responses.count, completions: progresses }
      grouped.merge!(responses_hash => data)
    end

    grouped
  end
end
