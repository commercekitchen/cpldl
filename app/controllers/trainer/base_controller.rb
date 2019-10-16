# frozen_string_literal: true

module Trainer
  class BaseController < ApplicationController
    before_action :authorize_trainer

    layout 'trainer/base'

    def authorize_trainer
      unless current_user.present? && current_user.has_role?(:trainer, current_organization)
        redirect_to root_path, alert: 'Access denied.'
      end
    end
  end
end
