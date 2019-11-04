# frozen_string_literal: true

module Admin
  module Custom
    class BaseController < Admin::BaseController
      before_action :load_organization
      before_action -> { enable_sidebar('shared/admin/sidebar') }

      private

      def load_organization
        @organization = current_organization
      end
    end
  end
end
