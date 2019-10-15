# frozen_string_literal: true

class Admin::Custom::BaseController < Admin::BaseController
  before_action :set_sidebar

  private

  def set_sidebar
    @sidebar = 'shared/admin/customization_sidebar'
  end
end
