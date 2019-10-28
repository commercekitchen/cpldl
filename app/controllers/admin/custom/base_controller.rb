# frozen_string_literal: true

class Admin::Custom::BaseController < Admin::BaseController
  before_action :load_organization
  before_action -> { enable_sidebar('shared/admin/sidebar') }

  private

  def load_organization
    @organization = current_organization
  end
end
