class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout proc { user_signed_in? ? "logged_in" : "application" }

  def after_sign_in_path_for(user)
    if user.blocked?
      sign_out :user
      flash[:alert] = %Q[Your account has been placed on hold, please contact a site administrator.]
    elsif user.has_role?(:super) || user.has_role?(:admin)
      administrators_dashboard_index_path
    else
      root_path
    end
  end
end
