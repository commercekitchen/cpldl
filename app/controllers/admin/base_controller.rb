module Admin
  class BaseController < ApplicationController
    before_action :authorize_admin

    def authorize_admin
      unless current_user.present? && current_user.is_admin?
        redirect_to root_path, alert: "Access denied."
      end
    end

  end
end
