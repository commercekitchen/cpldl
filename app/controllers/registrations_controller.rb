class RegistrationsController < Devise::RegistrationsController
  prepend_before_action :set_library_card_login
  after_action :create_organization_user_entry

  def create
    @user = User.new(sign_up_params)
    if verify_recaptcha(model: @user)
      super
    else
      render :new
    end
  end

  protected

  def create_organization_user_entry
    if resource.persisted?
      resource.add_role :user, current_organization
    end
  end

  private

  def set_library_card_login
    @library_card_login = current_organization.library_card_login? && !params[:admin]
  end

  def sign_up_params

    if params[:user]["date_of_birth(1i)"].present?
      month = params[:user]["date_of_birth(2i)"].to_i
      day = params[:user]["date_of_birth(3i)"].to_i
      year = params[:user]["date_of_birth(1i)"].to_i
      params[:user][:date_of_birth] = Date.new(year, month, day)
    end

    if current_organization.library_card_login?
      params[:user] = convert_library_card_pin_to_password(params[:user])
    end

    if current_organization.accepts_custom_branches?
      params[:user][:profile_attributes] = convert_branch_params(params[:user][:profile_attributes])
    end

    params.require(:user).permit(list_params).merge(organization_id: current_organization.id)
  end

  def list_params
    list_params_allowed = [
      :email,
      :password,
      :password_confirmation,
      profile_attributes: profile_attributes
    ]

    list_params_allowed << [
      :parent_type,
      :program_id,
      :program_location_id,
      :library_card_number
    ] if current_organization.accepts_programs?

    list_params_allowed << [
      :acting_as,
      :student_id
    ] if params["program_type"] == "students_and_parents"

    list_params_allowed << [
      :date_of_birth,
      :grade,
      :school_id
    ] if params[:user][:acting_as] == "Student"

    list_params_allowed << [
      :library_card_number,
      :library_card_pin
    ] if current_organization.library_card_login?

    list_params_allowed
  end

  def convert_library_card_pin_to_password(user_params)
    return user_params if user_params[:library_card_pin].blank?

    hashed_pin = Digest::MD5.hexdigest(user_params[:library_card_pin]).first(10)
    user_params[:password] = hashed_pin
    user_params[:password_confirmation] = hashed_pin

    user_params
  end

  def profile_attributes
    allowed_attrs = [
      :first_name,
      :zip_code,
      :library_location_id
    ]

    allowed_attrs << [
      library_location_attributes: [
        :name,
        :custom,
        :zipcode
      ]
    ] if current_organization.accepts_custom_branches?

    allowed_attrs
  end

  def convert_branch_params(profile_params)
    if profile_params[:library_location_id].present?
      profile_params.except(:library_location_attributes)
    else
      library_location_zip = profile_params[:zip_code].presence || "00000"
      profile_params[:library_location_attributes][:zipcode] = library_location_zip
      profile_params
    end
  end

end
