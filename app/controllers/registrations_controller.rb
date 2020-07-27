# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  after_action :create_organization_user_entry

  def create
    skip_authorization

    @user = User.new(sign_up_params)
    @library_card_login = current_organization.library_card_login?
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

  def sign_up_params
    if current_organization.accepts_custom_branches?
      params[:user][:profile_attributes] = convert_branch_params(params[:user][:profile_attributes])
    end

    params.require(:user).permit(whitelisted_params).merge(organization_id: current_organization.id)
  end

  def whitelisted_params
    base_params = [:email, :password, :password_confirmation, profile_attributes: profile_attributes]

    base_params + programs_params + partner_params + library_card_params
  end

  def profile_attributes
    allowed_attrs = %i[
      first_name
      last_name
      zip_code
      library_location_id
    ]

    if current_organization.accepts_custom_branches?
      allowed_attrs << [
        library_location_attributes: %i[
          name
          custom
          zipcode
        ]
      ]
    end

    allowed_attrs
  end

  def programs_params
    allowed_programs_params = []

    if current_organization.accepts_programs?
      allowed_programs_params << %i[parent_type program_id program_location_id library_card_number]

      if params['program_type'] == 'students_and_parents'
        allowed_programs_params << %i[acting_as student_id]
      end

      if params[:user][:acting_as] == 'Student'
        allowed_programs_params << %i[grade school_id]
      end
    end

    allowed_programs_params
  end

  def partner_params
    current_organization.accepts_partners? ? [:partner_id] : []
  end

  def library_card_params
    if current_organization.library_card_login?
      %i[library_card_number library_card_pin]
    else
      []
    end
  end

  def convert_branch_params(profile_params)
    if profile_params[:library_location_id].present?
      profile_params.except(:library_location_attributes)
    else
      library_location_zip = profile_params[:zip_code].presence || '00000'
      profile_params[:library_location_attributes][:zipcode] = library_location_zip
      profile_params
    end
  end

end
