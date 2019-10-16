# frozen_string_literal: true

class MyCoursesController < ApplicationController
  before_action :authenticate_user!

  def index
    tracked_course_ids = current_user.course_progresses.tracked.collect(&:course_id)

    if params[:search].present?
      result_ids = PgSearch.multisearch(params[:search]).includes(:searchable).where(searchable_id: tracked_course_ids).map(&:searchable).map(&:id)
      @results = Course.where(id: result_ids)
    end

    @courses = params[:search].blank? ? Course.where(id: tracked_course_ids) : @results
    @skip_quiz = current_user.profile.opt_out_of_recommendations

    @category_ids = current_organization.categories.enabled.map(&:id)
    @disabled_category_ids = current_organization.categories.disabled.map(&:id)
    @disabled_category_courses = @courses.where(category_id: @disabled_category_ids)
    @uncategorized_courses = @courses.where(category_id: nil) + @disabled_category_courses

    respond_to do |format|
      format.html { render :index }
      format.json { render json: @courses }
    end
  end

end
