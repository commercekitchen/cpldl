# frozen_string_literal: true

module Admin
  class FooterLinksController < BaseController
    before_action :enable_sidebar

    def index
      @footer_links = policy_scope(FooterLink)
      @new_link = current_organization.footer_links.new
    end

    def create
      @link = current_organization.footer_links.build(footer_link_params)
      authorize @link

      @link.save

      respond_to do |format|
        format.html { redirect_to action: 'index' }
        format.js {}
      end
    end

    def destroy
      @link = FooterLink.find(params[:id])
      authorize @link

      @link.destroy

      respond_to do |format|
        format.html { redirect_to action: 'index' }
        format.js {}
      end
    end

    private

    def footer_link_params
      params.require(:footer_link).permit(:label, :url)
    end
  end
end
