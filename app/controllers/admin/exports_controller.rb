module Admin
  class ExportsController < BaseController

    def completions
      respond_to do |format|
        format.html { redirect_to admin_dashboard_index_path }
        format.csv { send_data Export.to_csv_for_completion_report(data_for_completions_report) }
      end
    end

    def data_for_completions_report
      grouped = {}
      current_site = Organization.find_by(subdomain: request.subdomain)
      course_progs = CourseProgress.completed_with_profile
      zip_codes = course_progs.merge(User.with_role(:user, current_site)).pluck(:zip_code).uniq

      zip_codes.each do |z|
        progress_by_zip = course_progs.merge(User.with_role(:user, current_site)
                                      .joins(:profile).merge(Profile.where(zip_code: z)))
        progresses = {}

        progress_by_zip.each do |p|
          if progresses.key?(p.course.title)
            progresses.replace(p.course.title => progresses[p.course.title] + 1)
          else
            progresses.merge!(p.course.title => progress_by_zip.where(course_id: p.id).count)
          end
        end

        users_by_zip = User.with_role(:user, current_site).joins(:profile).merge(Profile.where(zip_code: z)).count

        data = { sign_ups: users_by_zip, completions: progresses }

        grouped.merge!(z => data)
      end

      grouped
    end
  end
end
