class CourseCompletionsController < ApplicationController
  before_action :authenticate_user!

  def index
    completed_ids = current_user.course_progresses.completed.collect(&:course_id)
    @courses = Course.where(id: completed_ids)

    respond_to do |format|
      format.html
      format.json { render json: @courses }
    end
  end

end
