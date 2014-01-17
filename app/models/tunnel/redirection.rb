class Tunnel::Redirection
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new env

    if redirect_url = Tunnel::Redirection.url_for(request)
      [ 302, { "Location" => redirect_url }, [] ]
    else
      @app.call env
    end
  end

  # build redirection target URL. Note that redirection is not possible
  # if the tunnel does not provide a https or http scheme.
  def self.url_for(request)
    # lookup tunnel.
    #
    # Note: Looking up a tunnel requires a single database request. However,
    # a typical usage scenarion would involve a single request to a fqdn,
    # after which the user will be redirected away anyway. So there should
    # not be many requests to begin with, and then they should appear in long
    # intervals - so caching seems not to improve things at this time.
    host, path_info, query_string = request.host, request.path_info, request.query_string
    return unless tunnel = Tunnel.where(fqdn: request.host).first

    # build redirection URL. This url is the URL of the public endpoint of
    # the tunnel. All requests that go there will be routed via the (auto)ssh
    # tunnel to the endpoint.
    #
    # Note that DNS for the domains name (<tunnel>.pipe2.me) resolves to
    # this server (or else the request wouldn't end up here). It is important
    # to keep the name intact, as any SSL certificate in use on the start
    # point must match the name of the request. As a result the target differs
    # from the request url only by the port number.
    url = tunnel.urls(:https).first || tunnel.urls(:http).first
    return unless url

    url += path_info
    url += "?#{query_string}" if query_string.present?
    url
  end
end
