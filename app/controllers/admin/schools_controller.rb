# frozen_string_literal: true

module Admin
  class SchoolsController < BaseController

    def index
      @schools = current_organization.schools
      @new_school = current_organization.schools.new

      render layout: 'admin/base_with_sidebar'
    end

    def create
      @school = current_organization.schools.create(school_params)

      respond_to do |format|
        format.html do
          redirect_to action: 'index'
        end

        format.js {}
      end
    end

    def toggle
      @school = School.find(params[:school_id])
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
      params.require(:school).permit(:school_name)
    end

  end
end
