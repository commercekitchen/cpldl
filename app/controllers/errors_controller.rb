# frozen_string_literal: true

class ErrorsController < ApplicationController
  def error404
    skip_authorization
    render status: :not_found
  end

  def error500
    skip_authorization
    render status: :internal_server_error
  end
end
