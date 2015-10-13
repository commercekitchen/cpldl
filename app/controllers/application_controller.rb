class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout Proc.new { |controller| user_signed_in? ? "logged_in" : "application" }

  def after_sign_in_path_for(user)
    # sign_in_url = new_user_session_path

    if user.blocked?
      sign_out :user
      flash[:alert] = %Q[Your account has been placed on hold, please contact a site administrator.]
    elsif user.has_role?(:super) || user.has_role?(:admin)
      administrators_path
    else
      root_path
    end
  end

  def authenticate
    if current_user.nil?
      redirect_to root_path
      flash[:alert] = %Q[You must be Logged In to do that. Please <a href="/user_accounts/new">Log In</a> and try again.]
    elsif current_user.has_role?(:super) || current_user.has_role?(:admin)
      return true
    else
      redirect_to root_path
      flash[:alert] = %Q[You don't have permission to do that | If you feel this wrong please contact a site administrator.]
    end
  end
end
