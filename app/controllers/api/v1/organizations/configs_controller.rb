module Api
  module V1
    module Organizations
      class ConfigsController < ::Api::V1::BaseController
        def show
          render json: OrganizationConfigPresenter.new(current_organization, request: request).as_json
        end
      end
    end
  end
end
