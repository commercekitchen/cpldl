# frozen_string_literal: true

class ErrorsController < ApplicationController
  def error404
    render layout: 'errors_layout', status: :not_found
  end

  def error500
    render layout: 'errors_layout', status: :internal_server_error
  end
end
