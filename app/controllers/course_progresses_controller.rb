class CourseProgressesController < ApplicationController
  before_action :authenticate_user!, except: [:create]
  before_action :assign_course

  def create
    if current_user
      course_progress = current_user.course_progresses.find_or_create_by(course_id: @course.id)
      course_progress.tracked = true
      if course_progress.save
        redirect_to course_lesson_path(@course, course_progress.next_lesson_id)
      else
        render :show, alert: "Sorry, we were unable to add this course to your plan."
      end
    else
      redirect_to course_lesson_path(@course, @course.next_lesson_id)
    end
  end

  def update
    tracked = params[:tracked] == "true"
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
