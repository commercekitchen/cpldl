# frozen_string_literal: true

module Admin
  class SchoolsController < BaseController
    before_action :enable_sidebar

    def index
      @schools = policy_scope(School).order(Arel.sql('lower(school_name)'))
      @new_school = current_organization.schools.new
    end

    def create
      @school = current_organization.schools.build(school_params)
      authorize @school

      @school.save
      respond_to do |format|
        format.html do
          redirect_to action: 'index'
        end

        format.js {}
      end
    end

    def update
      @school = @school = School.find(params[:id])
      authorize @school

      respond_to do |format|
        format.html { redirect_to action: 'index' }
        format.js do
          @school.update(school_params)
        end
      end
    end

    def toggle
      @school = School.find(params[:school_id])
      authorize @school, :update?
      currently_enabled = @school.enabled?
      @school.update(enabled: !currently_enabled)

      respond_to do |format|
        format.html do
          redirect_to action: 'index'
        end

        format.js {}
      end
    end

    private

    def school_params
      params.require(:school).permit(:school_name, :school_type)
    end

  end
end
