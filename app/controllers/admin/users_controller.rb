module Admin
  class UsersController < BaseController
    def change_user_roles
      user     = User.find(params[:id])
      org      = user.roles.find_by_resource_type("Organization").nil? ? current_organization : user.organization
      new_role = params[:value].downcase.to_sym

      user.roles = []
      user.add_role(new_role, org)

      if user.save
        render status: 200, json: "#{user.current_roles}"
      else
        render status: :unprocessable_entity, json: "roles failed to update"
      end
    end
  end
end
