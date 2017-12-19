require "csv"

class RegistrationExporter

  def initialize(org)
    @org = org
  end

  def to_csv
    users = User.includes(:roles).where(organization_id: @org).order(:email)
    CSV.generate do |csv|
      csv << ["Email", "Program Name", "Registration Date"]
      users.each do |user|
        if user.reportable_role?(@org)
          program_name = user.program.present? ? user.program.program_name : ""
          values = [user.email, program_name, user.created_at]
          csv.add_row values
        end
      end
    end
  end

end
