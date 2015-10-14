class LessonsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_course

  def index
    @lessons = @course.lessons.all
    respond_to do |format|
      format.html { render :index }
      format.json { render json: @lessons }
    end
  end

  def show
    @lesson = @course.lessons.find(params[:id])
    respond_to do |format|
      format.html { render :show }
      format.json { render json: @lesson }
    end
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

end
