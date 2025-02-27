# frozen_string_literal: true

module Admin
  class ReportsController < BaseController
    before_action :enable_sidebar

    def show
      authorize current_organization, :download_reports?
      @start_date = params[:start_date] || Time.zone.now.beginning_of_year.strftime('%Y-%m-%d')
      @end_date = params[:end_date] || Time.zone.now.strftime('%Y-%m-%d')
    end

  end
end
