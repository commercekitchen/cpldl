class CoursesController < ApplicationController

  def index
    @courses = Course.all
    respond_to do |format|
      format.html { render :index }
      format.json { render json: @courses }
    end
  end

  def show
    @course = Course.find(params[:id])
    respond_to do |format|
      format.html { render :show }
      format.json { render json: @course }
    end
  end

end
