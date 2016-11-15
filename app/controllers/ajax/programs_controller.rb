module Ajax
  class ProgramsController < ApplicationController

    def select_program
      @program = Program.find(params[:program_id])

      respond_to do |format|
        format.json { render json: @program.to_json(include: [:program_locations]) , status: :ok }
      end
    end

  end
end