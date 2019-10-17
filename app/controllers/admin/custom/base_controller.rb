# frozen_string_literal: true

class Admin::Custom::BaseController < Admin::BaseController
  before_action :load_organization
  before_action :set_sidebar

  private

  def load_organization
    @organization = current_organization
  end

  def set_sidebar
    @sidebar = 'shared/admin/customization_sidebar'
  end
end
