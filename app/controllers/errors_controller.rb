# frozen_string_literal: true

class ErrorsController < ApplicationController
  def error404
    render status: :not_found
  end

  def error500
    render status: :internal_server_error
  end
end
