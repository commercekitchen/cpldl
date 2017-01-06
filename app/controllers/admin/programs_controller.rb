module Admin
  class ProgramsController < BaseController

    def new
      @program = current_organization.programs.build
      render layout: "admin/base_with_sidebar"
    end

    def create
      @program = current_organization.programs.build

      if @program.update(program_params)
        redirect_to admin_programs_path, notice: "Program created successfully"
      else
        render :new
      end
    end

    def index
      @programs = current_organization.programs
      render layout: "admin/base_with_sidebar"
    end

    def edit
      @program = Program.find(params[:id])
      @program_location = @program.program_locations.new
      render layout: "admin/base_with_sidebar"
    end

    private

    def program_params
      params.require(:program)
        .permit(:program_name, :location_required, :parent_type,
          :program_location_attributes => [:id, :location_name])
    end

  end
end