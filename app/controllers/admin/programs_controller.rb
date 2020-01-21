# frozen_string_literal: true

module Admin
  class ProgramsController < BaseController
    before_action :enable_sidebar

    def new
      @program = current_organization.programs.build
      authorize @program
    end

    def create
      @program = current_organization.programs.build
      authorize @program

      if @program.update(program_params)
        redirect_to admin_programs_path, notice: 'Program created successfully'
      else
        render :new
      end
    end

    def index
      @programs = policy_scope(Program)
    end

    def edit
      @program = Program.find(params[:id])
      authorize @program

      @program_location = @program.program_locations.new
    end

    private

    def program_params
      params.require(:program)
            .permit(:program_name, :location_required, :parent_type,
                    program_location_attributes: %i[id location_name])
    end

  end
end
