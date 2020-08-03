# frozen_string_literal: true

module Ajax
  class SchoolsController < ApplicationController
    skip_after_action :verify_policy_scoped, only: :index

    def index
      @schools = current_organization.schools
                                     .where(school_type: params[:school_type])
                                     .enabled
                                     .order(School.arel_table['school_name'].lower.asc)
      render json: @schools
    end

  end
end
