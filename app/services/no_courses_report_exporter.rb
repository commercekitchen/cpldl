require "csv"

class NoCoursesReportExporter

  def initialize(org)
    @org = org
  end

  def to_csv
    users = User.includes(:roles).where(organization_id: @org).order(:email)
    CSV.generate do |csv|
      csv << ["Email", "Registration Date"]
      users.each do |user|
        if user.course_progresses.size.zero? && user.reportable_role?(@org)
          values = [user.email, user.created_at]
          csv.add_row values
        end
      end
    end
  end

end
