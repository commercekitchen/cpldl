# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin

    def authorize_admin
      unless current_user.present? && current_user.admin?
        redirect_to root_path, alert: 'Access denied.'
      end
    end

    def authorize_admin_or_trainer
      unless current_user.present? && admin_or_trainer_at(current_organization)
        redirect_to root_path, alert: 'Access denied.'
      end
    end

    protected

    def admin_or_trainer_at(organization)
      current_user.admin? || current_user.has_role?(:trainer, organization)
    end
  end
end
