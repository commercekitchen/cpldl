require 'rack-proxy'

class S3Proxy < Rack::Proxy
  def perform_request(env)
    request = Rack::Request.new(env)

    puts request.path

    # use rack proxy for anything hitting our host app at /example_service
    if request.path =~ %r{^/storylines}
        @backend = URI('http://dl-development-assets.s3-us-west-2.amazonaws.com')
        # most backends required host set properly, but rack-proxy doesn't set this for you automatically
        # even when a backend host is passed in via the options
        env['HTTP_HOST'] = @backend.host

        # This is the only path that needs to be set currently on Rails 5 & greater
        env['PATH_INFO'] = request.fullpath
        
        # don't send your sites cookies to target service, unless it is a trusted internal service that can parse all your cookies
        env['HTTP_COOKIE'] = ''
        super(env)
    else
      @app.call(env)
    end
  end
end