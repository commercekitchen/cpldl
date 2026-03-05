# frozen_string_literal: true

module Api
  module V1
    class CsrfController < BaseController
      def show
        raise ActionController::RoutingError, "Not Found" unless Rails.env.development?

        render json: { token: form_authenticity_token }
      end
    end
  end
end
