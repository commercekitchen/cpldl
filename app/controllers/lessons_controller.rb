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
    @lesson = @course.lessons.friendly.find(params[:id])
    @next_lesson = @course.lessons.find(@course.next_lesson_id(@lesson.id))
    @course_progress = CourseProgress.find_by_user_id_and_course_id(current_user.id, @course.id)
    respond_to do |format|
      format.html do
        # Need to handle the change of course slug, which should 301 redirect.
        if request.path != course_lesson_path(@course, @lesson)
          redirect_to course_lesson_path(@course, @lesson), status: :moved_permanently
        else
          render :show
        end
      end
      format.json { render json: @lesson }
    end
  end

  def complete
    lesson = @course.lessons.friendly.find(params[:lesson_id])

    # TODO: move to user model?
    course_progress = current_user.course_progresses.where(course_id: @course).first_or_create
    course_progress.completed_lessons.where(lesson_id: lesson.id).first_or_create

    respond_to do |format|
      format.html do
        redirect_to course_lesson_path(@course, @course.next_lesson_id(lesson.id))
      end
      format.json { render status: :ok, json: { next_lesson: course_lesson_path(@course, @course.next_lesson_id(lesson.id)) } }
    end
  end

  private

  def set_course
    @course = Course.friendly.find(params[:course_id])
  end

end
