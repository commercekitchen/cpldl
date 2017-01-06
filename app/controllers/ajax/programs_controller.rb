module Ajax
  class ProgramsController < ApplicationController

    def get_sub_programs
      @programs = Program.where(parent_type: Program.parent_types[params[:parent_type].to_sym])

      respond_to do |format|
        format.json { render json: @programs.to_json, status: :ok }
      end
    end

    def select_program
      @program = Program.find(params[:program_id])

      respond_to do |format|
        format.json { render json: @program.to_json(include: [:program_locations]) , status: :ok }
      end
    end

  end
end