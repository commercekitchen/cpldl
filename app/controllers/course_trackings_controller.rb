class CourseTrackingsController < ApplicationController
  before_action :authenticate_user!
  before_action :assign_course

  def update
    course_progress.tracked = true

    if course_progress.save
      redirect_to course_path(@course), notice: "Successfully added this course to your plan."
    else
      render :show, alert: "Sorry, we were unable to add this course to your plan."
    end
  end

  def destroy
    course_progress.tracked = false

    if course_progress.save
      redirect_to course_path(@course), notice: "Successfully removed this course to your plan."
    else
      render :show, alert: "Sorry, we were unable to remove this course to your plan."
    end
  end

  private

    def assign_course
      @course = Course.friendly.find(params[:course_id])
    end

    def course_progress
      @course_progress ||= CourseProgress.where(user: current_user, course_id: @course.id).first_or_create
    end

end
