# frozen_string_literal: true

module Api
  module V1
    module Admin
      class LibraryLocationsController < ::Api::V1::BaseController
        before_action :require_admin
        before_action :set_location, only: [:update, :destroy]

        def create
          location = current_organization.library_locations.build(location_params)
          if location.save
            render json: location_payload(location), status: :created
          else
            render status: :unprocessable_entity, json: { errors: location.errors.full_messages }
          end
        end

        def update
          if @location.update(location_params)
            render json: location_payload(@location)
          else
            render status: :unprocessable_entity, json: { errors: @location.errors.full_messages }
          end
        end

        def destroy
          @location.destroy
          head :no_content
        end

        private

        def require_admin
          unless current_user&.admin?
            render status: :forbidden, json: { message: 'You are not authorized to perform this action.' }
          end
        end

        def set_location
          @location = current_organization.library_locations.find(params[:id])
        end

        def location_params
          params.require(:library_location).permit(:name, :zipcode)
        end

        def location_payload(loc)
          { id: loc.id, name: loc.name, zipcode: loc.zipcode, sortOrder: loc.sort_order }
        end
      end
    end
  end
end
