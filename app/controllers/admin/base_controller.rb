module Admin
  class BaseController < ApplicationController
    before_action :authorize_admin

    layout "admin/base"

    def authorize_admin
      unless current_user.present? && current_user.has_role?(:admin, Organization.find_by_subdomain( Rails.application.config.subdomain_site))
        redirect_to root_path, alert: "Access denied."
      end
    end
  end
end
