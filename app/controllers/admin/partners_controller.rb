# frozen_string_literal: true

module Admin
  class PartnersController < BaseController
    before_action :enable_sidebar

    def index
      @partners = current_organization.partners
      @new_partner = current_organization.partners.new
    end

    def create
      @partner = current_organization.partners.create(partner_params)

      respond_to do |format|
        format.html { redirect_to action: 'index' }
        format.js {}
      end
    end

    def destroy
      @partner = current_organization.partners.find_by(id: params[:id])
      @partner.destroy if @partner.present?

      respond_to do |format|
        format.html { redirect_to action: 'index' }
        format.js {}
      end
    end

    private

    def partner_params
      params.require(:partner).permit(:name)
    end
  end
end
