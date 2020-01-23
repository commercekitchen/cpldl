# frozen_string_literal: true

module Trainer
  class DashboardController < BaseController

    def index
      users = policy_scope(User).includes(profile: [:language])
      @users = if params[:search].blank?
                 users
               else
                 users.search_users(params[:search])
               end
      render 'trainer/dashboard/index'
    end

    def manually_confirm_user
      @user = User.find(params[:user_id])
      authorize @user, :confirm?

      @user.confirm
      redirect_to trainer_dashboard_index_path
    end
  end
end
