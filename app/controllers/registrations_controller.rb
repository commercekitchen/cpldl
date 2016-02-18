class RegistrationsController < Devise::RegistrationsController
  after_action :create_organization_user_entry

  protected

  def create_organization_user_entry
    # TODO: Make this create the appropriate connection once we have real orgs.
    # Not be hardcoded to "chipublib". We will need to pull it in with
    # request.subdomain
    if resource.persisted?
      resource.add_role :user, Organization.find_by_subdomain(@user.subdomain)
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation,
      :subdomain, profile_attributes: [:first_name, :zip_code])
  end
end
