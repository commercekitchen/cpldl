# frozen_string_literal: true

class CoursesController < ApplicationController
  include UserCourses

  before_action :authenticate_user!, only: :quiz_submit

  def index
    @courses = policy_scope(Course)

    if params[:search].present?
      result_ids = PgSearch.multisearch(params[:search]).includes(:searchable).map(&:searchable).compact.map(&:id)

      # Only courses are multisearchable right now, so this works
      # If another class is made multisearchable, this won't work as intended
      # PgSearch multisearch isn't working well here - I'm running into
      # an issue similar to https://github.com/rails/rails/issues/13648
      # when I try to chain PgSearch results with AR queries.
      published_results = Course.where(id: result_ids)
      @courses = @courses.merge(published_results)
    end

    respond_to do |format|
      format.html { render :index }
      format.json { render json: @courses }
    end
  end

  def show
    @course = Course.friendly.find(params[:id])
    authorize @course

    case @course.pub_status
    when 'D'
      flash[:notice] = 'That course is not avaliable at this time.'
      redirect_to root_path
    when 'A'
      flash[:notice] = 'That course is no longer avaliable.'
      redirect_to root_path
    when 'P'
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

  def view_attachment
    @course = Course.friendly.find(params[:course_id])
    authorize @course, :show?

    extension = File.extname(@course.attachments.find(params[:attachment_id]).document_file_name)
    file_options = if extension == '.pdf'
                     { disposition: 'inline', type: 'application/pdf', x_sendfile: true }
                   else
                     { disposition: 'attachment', type: ['application/msword',
                                                         'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                                                         'application/vnd.openxmlformats-officedocument.presentationml.presentation'],
                       x_sendfile: true }
                   end
    send_file @course.attachments.find(params[:attachment_id]).document.path, file_options
  end

  def skills
    @course = Course.friendly.find(params[:course_id])
  end

  def designing_courses_1; end

  def designing_courses_2; end

  private

  def find_language_id_by_session
    case session[:locale]
    when 'en'
      1
    when 'es'
      2
    end
  end

end
