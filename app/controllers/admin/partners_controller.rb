# frozen_string_literal: true

module Admin
  class PartnersController < BaseController
    before_action :enable_sidebar

    def index
      @partners = policy_scope(Partner)
      @new_partner = current_organization.partners.new
    end

    def create
      @partner = current_organization.partners.build(partner_params)
      authorize @partner

      @partner.save

      respond_to do |format|
        format.html { redirect_to action: 'index' }
        format.js {}
      end
    end

    def destroy
      @partner = Partner.find(params[:id])
      authorize @partner

      @partner.destroy

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
