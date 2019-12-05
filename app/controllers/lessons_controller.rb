# frozen_string_literal: true

class LessonsController < ApplicationController
  before_action :auth_subsites
  before_action :set_course

  def show
    @lesson = @course.lessons.friendly.find(params[:id])

    case @lesson.pub_status
    when 'D'
      flash[:notice] = 'That lesson is not avaliable at this time.'
      redirect_to root_path
    when 'A'
      flash[:notice] = 'That lesson is no longer avaliable.'
      redirect_to root_path
    when 'P'
      unless current_user
        session[:lessons_done] = [] if session[:lessons_done].blank?
        session[:lessons_done] << @lesson.id unless session[:lessons_done].include?(@lesson.id)
      end

      @next_lesson = @course.lessons.find(@course.next_lesson_id(@lesson.id))

      if current_user
        @course_progress = CourseProgress.where(user_id: current_user.id, course_id: @course.id).first_or_create
        @course_progress.update_attribute(:tracked, true)
      else
        session[:course_id] = @course.id if session[:course_id].blank?
        @course_progress = CourseProgress.new(course_id: session[:course_id], tracked: true)
      end

      respond_to do |format|
        format.html do
          # The change of course slug should 301 redirect.
          if request.path != course_lesson_path(@course, @lesson)
            redirect_to course_lesson_path(@course, @lesson), status: :moved_permanently
          else
            render :show
          end
        end
        format.json { render json: @lesson }
      end
    end
  end

  def lesson_complete
    @current_lesson = @course.lessons.friendly.find(params[:lesson_id])
    @next_lesson = @course.lessons.find(@course.next_lesson_id(@current_lesson.id))
  end

  def complete
    lesson = @course.lessons.friendly.find(params[:lesson_id])

    # TODO: move to user model?
    if current_user
      course_progress = current_user.course_progresses.where(course_id: @course).first_or_create
      course_progress.completed_lessons.where(lesson_id: lesson.id).first_or_create
      course_progress.completed_at = Time.zone.now if lesson.is_assessment
      course_progress.save
    else
      session[:completed_lessons] ||= []
      session[:completed_lessons] << lesson.id unless session[:completed_lessons].include?(lesson.id)
    end

    respond_to do |format|
      format.json do
        if lesson.is_assessment
          render status: :ok, json: { redirect_path: course_completion_path(@course) }
        else
          render status: :ok, json: { redirect_path: course_lesson_lesson_complete_path(@course, lesson) }
        end
      end
    end
  end

  private

  def set_course
    @course = Course.friendly.find(params[:course_id])
  end

  def auth_subsites
    if current_organization.login_required?
      authenticate_user!
    end
  end
end
