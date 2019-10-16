# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :authorize_admin

    layout 'admin/base'

    def authorize_admin
      unless current_user.present? && current_user.has_role?(:admin, current_organization)
        redirect_to root_path, alert: 'Access denied.'
      end
    end
  end
end
