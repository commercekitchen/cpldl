# frozen_string_literal: true

module Api
  module V1
    class InvitationsController < Api::V1::BaseController
      before_action :skip_authorization

      def update
        user = User.accept_invitation!(
          invitation_token: params[:invitation_token].to_s,
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
