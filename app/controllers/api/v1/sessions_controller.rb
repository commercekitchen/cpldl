# frozen_string_literal: true

module Api
  module V1
    class SessionsController < Api::V1::BaseController
      before_action :skip_authorization

      def create
        if current_organization.phone_number_users_enabled && phone_number_login_request?
          user = find_or_build_phone_number_user

          if user.blank? || user.organization_id != current_organization.id
            render status: :unauthorized, json: { message: 'Invalid phone number.' }
            return
          end

          if user.admin?
            render status: :forbidden, json: { message: 'Phone number sign-in is not allowed for admin accounts.' }
            return
          end

          unless user.valid?
            render status: :unprocessable_entity, json: { message: user.errors.full_messages.join(', ') }
            return
          end

          user.save! if user.new_record?
          user.add_role(:user, current_organization) unless user.has_role?(:user, current_organization)
          sign_in(:user, user)

          render json: session_payload(user)
          return
        end

        email = login_params[:email].to_s.strip.downcase
        password = login_params[:password].to_s

        user = User.find_for_authentication(email: email)

        if user.blank? || user.organization_id != current_organization.id || !user.valid_password?(password)
          render status: :unauthorized, json: { message: 'Invalid email or password.' }
          return
        end

        sign_in(:user, user)

        render json: session_payload(user)
      end

      def destroy
        sign_out(:user) if current_user
        render json: { ok: true }
      end

      private

      def login_params
        params.permit(:email, :password)
      end

      def phone_number_login_request?
        !params.key?(:user) && phone_number_param.present?
      end

      def phone_number_param
        params.dig(:phone_number, :phone).to_s.delete('^0-9')
      end

      def find_or_build_phone_number_user
        normalized_phone = phone_number_param
        return nil if normalized_phone.blank?

        user = User.find_by(phone_number: normalized_phone, organization: current_organization)
        return user if user

        # If the phone number belongs to a different organization, do not leak account details
        # and do not create a duplicate / conflicting record in this organization.
        return nil if User.exists?(phone_number: normalized_phone)

        User.new(phone_number: normalized_phone, organization: current_organization)
      end

      def post_login_redirect_for(user)
        stored_location_for(user) || (user.has_role?(:admin, user.organization) ? '/admin' : '/')
      end

      def session_payload(user)
        {
          id: user.id,
          email: user.email,
          organization_subdomain: user.organization.subdomain,
          is_org_admin: user.has_role?(:admin, user.organization),
          redirect_to: post_login_redirect_for(user)
        }
      end
    end
  end
end
