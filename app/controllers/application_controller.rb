class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout proc { user_signed_in? ? "user/logged_in" : "application" }

  def after_sign_in_path_for(user)
    if first_admin_login? user
      flash[:notice] = "This is the first time you have logged in, please change your password."
      profile_path
    elsif user.is_admin?
      admin_dashboard_index_path
    else
      root_path
    end
  end

  private

  def first_admin_login?(user)
    return true if user.sign_in_count == 1 && (user.is_super? || user.is_admin?)
    false
  end

end
