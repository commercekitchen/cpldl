# frozen_string_literal: true

module Api
  module V1
    class PasswordResetsController < Api::V1::BaseController
      before_action :skip_authorization

      def create
        user = User.find_by(email: params[:email].to_s.strip.downcase, organization: current_organization)

        # Always respond with success to avoid leaking whether an email is registered.
        user&.send_reset_password_instructions

        render json: { ok: true }
      end

      def update
        user = User.reset_password_by_token(
          reset_password_token: params[:reset_password_token].to_s,
          password: params[:password].to_s,
          password_confirmation: params[:password_confirmation].to_s
        )

        if user.errors.empty?
          sign_in(:user, user)
          render json: { ok: true }
        else
          render status: :unprocessable_entity, json: { message: user.errors.full_messages.join(', ') }
        end
      end
    end
  end
end
