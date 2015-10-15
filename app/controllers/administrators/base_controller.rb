class Administrators::BaseController < ApplicationController
  before_action :authorize

  def authorize
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
