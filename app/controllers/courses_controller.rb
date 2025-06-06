# frozen_string_literal: true

class CoursesController < ApplicationController
  def index
    @courses = policy_scope(Course).where(language: current_language, pub_status: ['P', 'C'])

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

    if current_user && current_organization.survey_required? && current_user.quiz_responses_object.blank?
      flash[:notice] = 'Please complete the Course Recommendation Survey before accessing courses.'
      redirect_to new_course_recommendation_survey_path and return
    end

    case @course.pub_status
    when 'D', 'C'
      flash[:notice] = 'That course is not avaliable at this time.'
      redirect_to root_path
    when 'A'
      flash[:notice] = 'That course is no longer avaliable.'
      redirect_to root_path
    when 'P'
      respond_to do |format|
        format.html do
          # Need to handle the change of course slug, which should 301 redirect.
          if request.path == course_path(@course)
            render :show
          else
            redirect_to @course, status: :moved_permanently
          end
        end
        format.json { render json: @course }
      end
    end
  end

  def skills
    @course = Course.friendly.find(params[:course_id])
    authorize @course, :show?
  end
end
