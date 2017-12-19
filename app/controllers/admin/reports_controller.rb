module Admin
  class ReportsController < BaseController

    def show
      render layout: "admin/base_with_sidebar"
    end

  end
end
