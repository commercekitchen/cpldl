# frozen_string_literal: true

class CustomPublicExceptions < ActionDispatch::PublicExceptions
  def call(env)
    request = ActionDispatch::Request.new(env)
    status  = env["PATH_INFO"][1..-1] # "404" or "500"

    if %w[404 500].include?(status)
      if api_request?(request)
        return render_api_error(status.to_i)
      else
        return Rails.application.routes.call(env)
      end
    end

    super
  end

  private

  def api_request?(request)
    request.path.start_with?("/api/") ||
      request.format.json? ||
      request.get_header("HTTP_ACCEPT").to_s.include?("application/json")
  end

  def render_api_error(status)
    body =
      case status
      when 404
        { error: "not_found", message: "Not Found" }
      when 500
        { error: "internal_server_error", message: "Internal Server Error" }
      else
        { error: "error", message: "Error" }
      end

    [
      status,
      { "Content-Type" => "application/json; charset=utf-8" },
      [body.to_json]
    ]
  end
end

