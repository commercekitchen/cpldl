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
    params.require(:user).permit(:email,
                                 :password,
                                 :password_confirmation,
                                 :subdomain,
                                 profile_attributes: [:first_name,
                                                      :zip_code,
                                                      :library_location_id]
                                ).merge(organization_id: current_organization.id)
  end
end
