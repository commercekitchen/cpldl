# frozen_string_literal: true

module Trainer
  class DashboardController < BaseController

    def index
      results = User.search_users(params[:search])
      if params[:search].blank?
        @users = User.includes(profile: [:language]).with_any_role({ name: :user, resource: current_user.organization }, { name: :admin, resource: current_user.organization })
      else
        @users = results & User.includes(profile: [:language]).with_any_role({ name: :user, resource: current_user.organization }, { name: :trainer, resource: current_user.organization })
      end
      render 'trainer/dashboard/index', layout: 'user/logged_in_with_sidebar'
    end

    def manually_confirm_user
      User.find(params[:user_id]).confirm if current_user.has_role?(:trainer, current_organization)
      redirect_to trainer_dashboard_index_path
    end
  end
end
