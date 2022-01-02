# frozen_string_literal: true

module Admin
  class OrganizationsController < BaseController
    def index
      @organizations = policy_scope(Organization)
    end

    def update
      @organization = Organization.find(params[:id])
      authorize @organization

      if @organization.update(organization_params)
        render json: { organization: @organization }, status: :ok
      else
        render json: { errors: @organization.errors }, status: :unprocessable_entity
      end
    rescue Pundit::NotAuthorizedError
      flash.now[:error] = 'You do not have access to this subdomain'
      render json: { errors: ['You do not have access to this subdomain'] }, status: :forbidden
    end

    private

    def organization_params
      params.require(:organization)
            .permit(:name,
                    :subdomain,
                    :branches,
                    :accepts_programs,
                    footer_links_attributes: %i[label url id _destroy])
    end
  end
end
