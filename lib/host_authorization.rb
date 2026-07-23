# frozen_string_literal: true

# Rack middleware that rejects requests whose Host header isn't in an
# allowed list. Rails 5.2 doesn't have ActionDispatch::HostAuthorization
# (added in Rails 6's config.hosts), so this fills the same role: it stops
# Host header injection (e.g. password reset link poisoning) by returning
# 400 before the request reaches the app.
class HostAuthorization
  def initialize(app, allowed_hosts:)
    @app = app
    @allowed_hosts = allowed_hosts
  end

  def call(env)
    host = env['HTTP_HOST'].to_s.split(':').first

    if allowed?(host)
      @app.call(env)
    else
      [400, { 'Content-Type' => 'text/plain' }, ["Bad Request: invalid host\n"]]
    end
  end

  private

  def allowed?(host)
    @allowed_hosts.any? do |allowed|
      allowed.is_a?(Regexp) ? allowed.match?(host) : allowed == host
    end
  end
end
