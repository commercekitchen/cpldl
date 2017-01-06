 class RegistrationsController < Devise::RegistrationsController
  after_action :create_organization_user_entry

  protected

  def create_organization_user_entry
    if resource.persisted?
      resource.add_role :user, current_organization
    end
  end

  private

  def sign_up_params

    if params[:user]["date_of_birth(1i)"].present?
      month = params[:user]["date_of_birth(2i)"].to_i
      day = params[:user]["date_of_birth(3i)"].to_i
      year = params[:user]["date_of_birth(1i)"].to_i
      params[:user][:date_of_birth] = Date.new(year, month, day)
    end

    params.require(:user).permit(list_params).merge(organization_id: current_organization.id)
  end

  def list_params
    list_params_allowed = [
      :email,
      :password,
      :password_confirmation,
      profile_attributes: [:first_name,
                           :zip_code,
                           :library_location_id]
    ]

    list_params_allowed << [
      :parent_type,
      :organization_program,
      :program_location_id,
      :library_card_number,
    ] if current_organization.accepts_programs?

    list_params_allowed << [
      :acting_as,
      :student_id,
    ] if params["program_type"] == "students_and_parents"

    list_params_allowed << [
      :date_of_birth,
      :grade,
      :school_id
    ] if params[:user][:acting_as] == "Student"

    list_params_allowed
  end
end
