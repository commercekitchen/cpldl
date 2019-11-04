# frozen_string_literal: true

module Admin
  module Custom
    class FootersController < Admin::Custom::BaseController
      def show; end

      def update
        if @organization.update(org_params)
          flash[:info] = 'Organization footer updated.'
          redirect_to admin_custom_footers_path
        else
          flash[:error] = @organization.errors.full_messages
          render :show
        end
      end

      private

      def org_params
        params.require(:organization).permit(:footer_logo_link, :footer_logo)
      end
    end
  end
end
