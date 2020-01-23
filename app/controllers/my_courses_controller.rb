# frozen_string_literal: true

class MyCoursesController < ApplicationController
  before_action :authenticate_user!

  def index
    @authorized_courses = policy_scope(Course)
    tracked_course_ids = current_user.course_progresses.tracked.collect(&:course_id)

    if params[:search].present?
      result_ids = PgSearch.multisearch(params[:search]).includes(:searchable).where(searchable_id: tracked_course_ids).map(&:searchable).map(&:id)
      @results = @authorized_courses.where(id: result_ids)
    end

    @courses = params[:search].blank? ? @authorized_courses.where(id: tracked_course_ids) : @results
    @skip_quiz = current_user.profile.opt_out_of_recommendations

    respond_to do |format|
      format.html { render :index }
      format.json { render json: @courses }
    end
  end
end
