class CoursesController < ApplicationController

  # before_action :authenticate_user!, only: [:your, :completed, :start]
  before_action :authenticate_user!, except: [:index, :show]

  def index
    @results = PgSearch.multisearch(params[:search]).includes(:searchable).map(&:searchable)
    @courses = if params[:search].nil? || params[:search].empty?
                 Course.includes(:lessons).all
               else
                 @results
               end

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

  def add
    @course = Course.friendly.find(params[:course_id])
    course_progress = current_user.course_progresses.where(course_id: @course.id).first_or_create
    course_progress.tracked = true
    if course_progress.save
      redirect_to course_path(@course), notice: "Successfully added this course to your plan."
    else
      render :show, alert: "Sorry, we were unable to add this course to your plan."
    end
  end

  def remove
    @course = Course.friendly.find(params[:course_id])
    course_progress = current_user.course_progresses.where(course_id: @course.id).first_or_create
    course_progress.tracked = false
    if course_progress.save
      redirect_to course_path(@course), notice: "Successfully removed this course to your plan."
    else
      render :show, alert: "Sorry, we were unable to remove this course to your plan."
    end
  end

  def start
    @course = Course.friendly.find(params[:course_id])
    course_progress = current_user.course_progresses.find_or_create_by(course_id: @course.id)
    course_progress.tracked = true
    if course_progress.save
      redirect_to course_lesson_path(@course, course_progress.next_lesson_id)
    else
      render :show, alert: "Sorry, we were unable to add this course to your plan."
    end
  end

  def complete
    # TODO: Do we want to ensure that the assessment was completed to get here?
    @course = Course.friendly.find(params[:course_id])
  end

  def your
    tracked_course_ids = current_user.course_progresses.tracked.collect(&:course_id)
    @courses = Course.where(id: tracked_course_ids)
    respond_to do |format|
      format.html { render :your }
      format.json { render json: @courses }
    end
  end

  def completed
    completed_ids = current_user.course_progresses.completed.collect(&:course_id)
    @courses = Course.where(id: completed_ids)

    respond_to do |format|
      format.html { render "completed_list", layout: "user/logged_in_with_sidebar" }
      format.json { render json: @courses }
    end
  end

  def view_attachment
    @course = Course.friendly.find(params[:course_id])
    pdf_options = { disposition: "inline", type: "application/pdf", x_sendfile: true }
    send_file @course.attachments.find(params[:attachment_id]).document.path, pdf_options
  end

end
