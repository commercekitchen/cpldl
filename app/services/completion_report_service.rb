# frozen_string_literal: true

class CompletionReportService
  def initialize(organization:)
    @organization = organization
  end

  def generate_completion_report(group_by:)
    Export.to_csv_for_completion_report(self.send("report_data_by_#{group_by}"))
  end

  private

  def report_data_by_partner
    partner_counts = subsite_users.includes(:partner).group('partners.id').pluck('partners.name', 'partners.id', Arel.sql('count(users)'))

    data = { version: 'partner' }

    partner_counts.each do |partner_name, partner_id, user_count|
      key = partner_name || 'No Partner Selected'
      completions_data = partner_completions(partner_id)
      data[key] = { sign_ups: user_count, completions: completions_data }
    end

    data
  end

  def partner_completions(partner_id)
    CourseProgress.completed
                  .merge(subsite_users)
                  .includes(:course, :user)
                  .where(users: { partner_id: partner_id })
                  .group('courses.title')
                  .pluck('courses.title', Arel.sql('count(course_progresses)'))
  end

  def subsite_users
    @organization.users
  end

  def report_data_by_zip_code
    grouped = { version: 'zip_code' }
    current_site = @organization
    course_progs = CourseProgress.completed_with_profile
    zip_codes = course_progs.merge(User.with_role(:user, current_site)).pluck(:zip_code).uniq

    zip_codes.each do |z|

      progress_by_zip = course_progs.merge(User.with_role(:user, current_site)
                                    .joins(:profile).merge(Profile.where(zip_code: z)))
      progresses = {}

      progress_by_zip.each do |p|
        unless progresses.key?(p.course.title)
          progresses.merge!(p.course.title => progress_by_zip.where(course_id: p.course.id).count)
        end
      end

      users_by_zip = User.with_role(:user, current_site).joins(:profile).merge(Profile.where(zip_code: z)).count

      data = { sign_ups: users_by_zip, completions: progresses }

      grouped.merge!(z => data)
    end

    grouped
  end

  def report_data_by_library
    grouped = { version: 'library' }
    current_site = @organization
    course_progs = CourseProgress.completed_with_profile
    lib_ids = course_progs.merge(User.with_role(:user, current_site)).pluck(:library_location_id).uniq

    lib_ids.each do |l_id|
      progress_by_location = course_progs.merge(User.with_role(:user, current_site)
                                         .joins(:profile).merge(Profile.where(library_location_id: l_id)))
      progresses = {}

      progress_by_location.each do |p|
        unless progresses.key?(p.course.title)
          progresses.merge!(p.course.title => progress_by_location.where(course_id: p.course.id).count)
        end
      end

      users_by_lib = User.with_role(:user, current_site).joins(:profile).merge(Profile.where(library_location_id: l_id)).count

      data = { sign_ups: users_by_lib, completions: progresses }

      grouped.merge!(l_id => data)
    end

    grouped
  end

  def report_data_by_survey_responses
    grouped = { version: 'survey_responses' }
    current_site = @organization
    course_progs = CourseProgress.completed_with_profile
    quiz_response_combinations = course_progs.merge(User.with_role(:user, current_site)).map { |prog| prog.user.quiz_responses_object }.compact.uniq

    quiz_response_combinations.each do |responses_hash|
      users_with_responses = User.with_role(:user, current_site).where('users.quiz_responses_object = ?', responses_hash.to_yaml)
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
