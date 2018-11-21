require "csv"

class RegistrationExporter

  def initialize(org)
    @org = org
    @primary_id_field = @org.authentication_key_field
  end

  def to_csv
    users = User.includes(:roles).where(organization_id: @org).order(:email, :library_card_number)
    CSV.generate do |csv|
      csv << headers

      users.each do |user|
        next unless user.reportable_role?(@org)
        program_name = user.program.present? ? user.program.program_name : ""
        values = [user.send(@primary_id_field), program_name, user.created_at]
        values.concat([user.library_location_name, user.library_location_zipcode])
        csv.add_row values
      end
    end
  end

  private

    def column_headers
      headers = [User.human_attribute_name(@primary_id_field), "Program Name", "Registration Date"]
      headers.concat(["Branch Name", "Zip"]) if @org.accepts_custom_branches?
      headers
    end

end
