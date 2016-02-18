class RegistrationsController < Devise::RegistrationsController
  after_action :create_organization_user_entry

  protected

  def create_organization_user_entry
    # TODO: Make this create the appropriate connection once we have real orgs.
    # Not be hardcoded to "chipublib". We will need to pull it in with
    # request.subdomain
    if resource.persisted?
      if request.subdomain == "www"
        resource.add_role :user, Organization.find_by_subdomain(request.subdomain)
      else
        resource.add_role :user, Organization.find_by_subdomain(subdomain)
      end
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation,
      profile_attributes: [:first_name, :zip_code])
  end
end
