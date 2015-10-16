class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout proc { user_signed_in? ? "logged_in" : "application" }

  def after_sign_in_path_for(user)
    if user.blocked? # TODO: I think this belongs in a before_action method, not here.
      sign_out :user
      flash[:alert] = "Your account has been placed on hold, please contact a site administrator."
    elsif user.has_role?(:super) && user.sign_in_count == 1
      flash[:notice] = "This is the first time you have logged in, please change your password."
      profile_path
    elsif user.has_role?(:super) || user.has_role?(:admin)
      administrators_dashboard_index_path
    else
      root_path
    end
  end

end
