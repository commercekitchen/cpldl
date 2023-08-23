# frozen_string_literal: true

module Admin
  class InvitesController < Devise::InvitationsController
    before_action :enable_sidebar, except: %i[edit update]
    before_action :skip_authorization, only: %i[edit update]

    def new
      authorize current_organization, :invite_user?
      super
    end

    def create
      authorize current_organization, :invite_user?
      user = User.find_by(email: params[:user][:email])

      if user
        flash[:alert] = 'The user already exists'
        redirect_to new_user_invitation_path
      else
        super
      end
    end

    def edit
      super
    end

    def update
      super
    end

    private

    def invite_resource
      organization = if params[:user][:organization_id]
                       Organization.find(params[:user][:organization_id])
                     else
                       current_organization
                     end

      AdminInvitationService.invite(email: params[:user][:email], organization: organization, inviter: current_user)
    end

    def after_accept_path_for(user)
      after_sign_in_path_for(user)
    end
  end
end
