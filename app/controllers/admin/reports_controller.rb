# frozen_string_literal: true

module Admin
  class ReportsController < BaseController
    before_action :enable_sidebar

    def show
      authorize current_organization, :download_reports?
    end

  end
end
