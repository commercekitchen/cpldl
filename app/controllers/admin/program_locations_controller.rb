# frozen_string_literal: true

module Admin
  class ProgramLocationsController < BaseController

    def create
      @program_location = ProgramLocation.new(location_params)
      authorize @program_location

      @program_location.save
      @program = @program_location.program

      respond_to do |format|
        format.js
      end
    end

    def toggle
      @program_location = ProgramLocation.find(params[:program_location_id])
      authorize @program_location, :update?

      currently_enabled = @program_location.enabled?
      @program_location.update(enabled: !currently_enabled)

      respond_to do |format|
        format.js
      end
    end

    private

    def location_params
      params.require(:program_location).permit(:location_name, :program_id)
    end

  end
end
