module Administrators
  class BaseController < ApplicationController
    before_action :authorize

    def authorize
      if current_user.nil?
        # TODO: Use dynamic path below, not hardcoded path.
        # TODO: Standardize language with devise language.
        flash[:alert] = "You must be Logged In to do that. Please <a href='/user_accounts/new'>Log In</a> and try again."
        redirect_to root_path
      elsif current_user.has_role?(:super) || current_user.has_role?(:admin)
        return true
      else
        flash[:alert] = "Permission denied. If you feel this wrong please contact a site administrator."
        redirect_to root_path
      end
    end
  end
end
