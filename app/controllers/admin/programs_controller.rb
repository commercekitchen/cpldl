module Admin
  class ProgramsController < BaseController
    def index
      @programs = current_organization.programs
      render layout: "admin/base_with_sidebar"
    end

    def edit
      @program = Program.find(params[:id])
      @program_location = @program.program_locations.new
      @location_field_name = @program.location_field_name
      render layout: "admin/base_with_sidebar"
    end

    private

    def program_params
      params.require(:program)
        .permit(:program_location_attributes => [:id, :location_name])
    end

  end
end