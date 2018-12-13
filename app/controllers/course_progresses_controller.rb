class CourseProgressesController < ApplicationController
  before_action :authenticate_user!
  before_action :assign_course

  def update
    tracked = params[:tracked] == "true" ? true : false
    course_progress.tracked = tracked

    if course_progress.save
      redirect_to course_path(@course), notice: success_message(tracked)
    else
      render :show, alert: error_message(tracked)
    end
  end

  private

    def assign_course
      @course = Course.friendly.find(params[:course_id])
    end

    def success_message(tracked)
      if tracked
        "Successfully added this course to your plan."
      else
        "Successfully removed this course to your plan."
      end
    end

    def error_message(tracked)
      if tracked
        "Sorry, we were unable to add this course to your plan."
      else
        "Sorry, we were unable to remove this course to your plan."
      end
    end

    def course_progress
      @course_progress ||= CourseProgress.where(user: current_user, course_id: @course.id).first_or_create
    end

end
