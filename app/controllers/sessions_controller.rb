# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  before_action :skip_authorization

  def new
    @library_card_login = current_organization.library_card_login? && !params[:admin]
    @phone_number_login = current_organization.phone_number_users_enabled && !params[:admin]
    super
  end

  def create
    if current_organization.phone_number_users_enabled && !params[:user] && phone_number_params.present?
      self.resource = warden.authenticate!(:phone_number)
      sign_in(resource_name, resource)
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      super
    end
  end

  private

  def phone_number_params
    params.require(:phone_number).permit(:phone)
  end
end
