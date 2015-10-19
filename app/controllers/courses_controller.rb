class CoursesController < ApplicationController

  def index
    @courses = Course.all
    respond_to do |format|
      format.html { render :index }
      format.json { render json: @courses }
    end
  end

  def show
    @course = Course.friendly.find(params[:id])
    respond_to do |format|
      format.html do
        # Need to handle the change of course slug, which should 301 redirect.
        if request.path != course_path(@course)
          redirect_to @course, status: :moved_permanently
        else
          render :show
        end
      end
      format.json { render json: @course }
    end
  end

end
