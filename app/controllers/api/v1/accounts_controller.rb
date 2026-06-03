# frozen_string_literal: true

module Api
  module V1
    class AccountsController < Api::V1::BaseController
      before_action :authenticate_user!
      before_action :skip_authorization

      def show
        return render_forbidden_org_mismatch unless current_user_in_current_org?

        render json: account_payload
      end

      def update
        return render_forbidden_org_mismatch unless current_user_in_current_org?

        update_user(account_params)

        if current_user.errors.any?
          render status: :unprocessable_entity, json: { errors: current_user.errors.full_messages }
        else
          render json: account_payload, status: :ok
        end
      end

      private

      def account_payload
        {
          account: {
            email: current_user.email
          }
        }
      end

      def account_params
        params.fetch(:account, {}).permit(:email, :password, :password_confirmation)
      end

      def update_user(params)
        email = params[:email]
        password = params[:password]
        password_confirmation = params[:password_confirmation]

        if password.blank? && password_confirmation.blank?
          if current_user.email != email && current_user.update(email: email)
            sign_in(:user, current_user, bypass: true)
          end
        elsif current_user.update(params)
          sign_in(:user, current_user, bypass: true)
        end
      end

      def current_user_in_current_org?
        current_user.organization_id == current_organization.id
      end

      def render_forbidden_org_mismatch
        render status: :forbidden, json: { message: 'You are not authorized to update this account.' }
      end
    end
  end
end
