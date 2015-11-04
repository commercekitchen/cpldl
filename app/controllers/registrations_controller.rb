class RegistrationsController < Devise::RegistrationsController

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation,
      profile_attributes: [:first_name, :zip_code])
  end
end
