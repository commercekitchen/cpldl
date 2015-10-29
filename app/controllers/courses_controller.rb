class CoursesController < ApplicationController

  before_action :authenticate_user!, only: [:your, :completed, :start]

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

  def start
    @course = Course.friendly.find(params[:course_id])
    course_progress = current_user.course_progresses.find_or_create_by(course_id: @course.id)
    redirect_to course_lesson_path(@course, course_progress.next_lesson_id)
  end

  def your
    @courses = []
    respond_to do |format|
      format.html { render :your }
      format.json { render json: @courses }
    end
  end

  def completed
    @courses = []
    respond_to do |format|
      format.html { render :completed }
      format.json { render json: @courses }
    end
  end

end
