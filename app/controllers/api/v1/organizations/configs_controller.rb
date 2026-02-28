module Api
  module V1
    module Organizations
      class ConfigsController < ::Api::V1::BaseController
        def show
          render json: OrganizationConfigPresenter.new(
            current_organization,
            request: request,
            current_user: current_user
          ).as_json
        end
      end
    end
  end
end
