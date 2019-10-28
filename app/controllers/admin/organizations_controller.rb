# frozen_string_literal: true

module Admin
  class OrganizationsController < BaseController
    def index
      @organizations = Organization.all
    end

    def new
      @organization = Organization.new
    end

    def create
      @organization = Organization.new(organization_params)

      if @organization.save
        redirect_to admin_organizations_path, notice: 'Organization was successfully created.'
      else
        render :new
      end
    end

    def update
      @organization = Organization.find(params[:id])

      if !current_user.has_role?(:admin, @organization)
        flash.now[:error] = 'You do not have access to this subdomain'
        render json: { errors: ['You do not have access to this subdomain'] }, status: :forbidden
      elsif @organization.update(organization_params)
        render json: { organization: @organization }, status: :ok
      else
        render json: { errors: @organization.errors }, status: :unprocessable_entity
      end
    end

    private

    def organization_params
      params.require(:organization).permit(:name, :subdomain, :branches, :accepts_programs)
    end
  end
end
