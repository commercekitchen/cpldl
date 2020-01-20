# frozen_string_literal: true

module Admin
  module Custom
    class BaseController < Admin::BaseController
      before_action :load_organization
      before_action :authorize_customization
      before_action -> { enable_sidebar('shared/admin/sidebar') }

      private

      def load_organization
        @organization = current_organization
      end

      def authorize_customization
        authorize @organization, :customize?
      end
    end
  end
end
