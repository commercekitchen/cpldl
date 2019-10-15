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

      if @organization.errors.any?
        render :new
      else @organization.save
        redirect_to admin_organizations_path, notice: 'Organization was successfully created.'
      end
    end

    private

    def organization_params
      params.require(:organization).permit(:name, :subdomain, :branches, :accepts_programs)
    end
  end
end
