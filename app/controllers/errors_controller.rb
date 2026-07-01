# frozen_string_literal: true

class ErrorsController < ApplicationController
  def error404
    skip_authorization
    skip_policy_scope
    if current_organization.use_spa?
      render 'spa/index', layout: 'spa', status: :not_found
    else
      respond_to do |format|
        format.html { render 'errors/error404', status: :not_found }
        format.any  { head :not_found }
      end
    end
  end

  def error500
    skip_authorization
    render status: :internal_server_error
  end
end
