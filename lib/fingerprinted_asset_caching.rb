# frozen_string_literal: true

# Rack middleware that gives content-hashed static files (Vite's /spa/assets
# and Sprockets' /assets) a far-future, immutable Cache-Control. Rails 5.2's
# public_file_server.headers is a single hash for every file in public/, so
# that stays at a short default for un-fingerprinted files (preview images,
# robots.txt, favicon) and this upgrades only the fingerprinted ones.
#
# Only responses still carrying the static-file default are touched, so a
# request that falls through to the app (e.g. a missing asset) isn't cached.
class FingerprintedAssetCaching
  IMMUTABLE = 'public, max-age=31536000, immutable'
  FINGERPRINTED_PREFIXES = ['/spa/assets/', '/assets/'].freeze

  def initialize(app, static_cache_control:)
    @app = app
    @static_cache_control = static_cache_control
  end

  def call(env)
    status, headers, body = @app.call(env)

    if status == 200 &&
       headers['Cache-Control'] == @static_cache_control &&
       FINGERPRINTED_PREFIXES.any? { |prefix| env['PATH_INFO'].start_with?(prefix) }
      headers['Cache-Control'] = IMMUTABLE
    end

    [status, headers, body]
  end
end
