require 'rack-proxy'

class S3Proxy < Rack::Proxy
  def perform_request(env)
    request = Rack::Request.new(env)

    puts request.path

    # use rack proxy for anything hitting our host app at /example_service
    if request.path =~ %r{^/storylines}
      @backend = URI('https://dl-development-assets.s3-us-west-2.amazonaws.com')

      # most backends required host set properly, but rack-proxy doesn't set this for you automatically
      # even when a backend host is passed in via the options
      env['HTTP_HOST'] = @backend.host

      # This is the only path that needs to be set currently on Rails 5 & greater
      env['PATH_INFO'] = request.fullpath
      
      # don't send your sites cookies to target service, unless it is a trusted internal service that can parse all your cookies
      env['HTTP_COOKIE'] = ''

      env['SERVER_PORT'] = '443'

      source_request = Rack::Request.new(env)

      # Initialize request
      if source_request.fullpath == ""
        full_path = URI.parse(env['REQUEST_URI']).request_uri
      else
        full_path = source_request.fullpath
      end

      target_request = Net::HTTP.const_get(source_request.request_method.capitalize).new(full_path)

      # Setup headers
      target_request.initialize_http_header(self.class.extract_http_request_headers(source_request.env))

      # Setup body
      if target_request.request_body_permitted? && source_request.body
        target_request.body_stream    = source_request.body
        target_request.content_length = source_request.content_length.to_i
        target_request.content_type   = source_request.content_type if source_request.content_type
        target_request.body_stream.rewind
      end

      backend = env.delete('rack.backend') || @backend || source_request

      puts "backend scheme: #{@backend.scheme}"
      use_ssl = @backend.scheme == "https"

      puts "use_ssl1: #{use_ssl}"
      ssl_verify_none = (env.delete('rack.ssl_verify_none') || @ssl_verify_none) == true
      read_timeout = env.delete('http.read_timeout') || @read_timeout

      # Create the response
      if @streaming
        # streaming response (the actual network communication is deferred, a.k.a. streamed)
        target_response = HttpStreamingResponse.new(target_request, backend.host, backend.port)
        target_response.use_ssl = use_ssl
        target_response.read_timeout = read_timeout
        target_response.verify_mode = OpenSSL::SSL::VERIFY_NONE if use_ssl && ssl_verify_none
        target_response.ssl_version = @ssl_version if @ssl_version
      else
        http = Net::HTTP.new(backend.host, backend.port)
        http.use_ssl = use_ssl if use_ssl
        http.read_timeout = read_timeout
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE if use_ssl && ssl_verify_none
        http.ssl_version = @ssl_version if @ssl_version

        puts ("use_ssl2: #{use_ssl}")
        http.set_debug_output($stdout)

        target_response = http.start do
          http.request(target_request)
        end
      end

      headers = self.class.normalize_headers(target_response.respond_to?(:headers) ? target_response.headers : target_response.to_hash)
      body    = target_response.body || [""]
      body    = [body] unless body.respond_to?(:each)

      # According to https://tools.ietf.org/html/draft-ietf-httpbis-p1-messaging-14#section-7.1.3.1Acc
      # should remove hop-by-hop header fields
      headers.reject! { |k| ['connection', 'keep-alive', 'proxy-authenticate', 'proxy-authorization', 'te', 'trailer', 'transfer-encoding', 'upgrade'].include? k.downcase }
      [target_response.code, headers, body]
    else
      @app.call(env)
    end
  end
end