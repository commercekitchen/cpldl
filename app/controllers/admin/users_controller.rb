module Admin
  class UsersController < BaseController
    def change_user_roles
      user = User.find(params[:id])
      org = user.organization
      # binding.pry
      if params[:roles_names].nil?
        User::ROLES.each do |role|
          user.remove_role(role.to_sym, org) if user.has_role?(role.to_sym, org)
          user.add_role(:user, org)
        end
      else
        User::ROLES.each do |role|
          case
          when params[:roles_names].include?(role) == false && user.has_role?(role.to_sym, org)
            user.remove_role(role.to_sym, org)
          when params[:roles_names].include?(role) && user.has_role?(role.to_sym, org) == false
            user.add_role(role.to_sym, org)
          end
        end
      end

      flash[:notice] = "Roles for #{user.email} were updated. #{user.profile.first_name.capitalize} now has the role(s) of #{user.current_roles.titleize}."
      redirect_to admin_users_index_path
    end
  end
end
