require "cache"

class Subdomain::Redirection
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new env

    if redirect_url = Subdomain::Redirection.url_for(request)
      [ 302, { "Location" => redirect_url }, [] ]
    else
      @app.call env
    end
  end

  @@finder = Cache.new(ttl: 60.seconds) do |subdomain_name|
    Subdomain.where(name: subdomain_name).first
  end

  # build redirection target URL. Note that the scheme might be tcp, in
  # which case this method returns a target URL, that might be invalid
  # for most http clients.
  def self.url_for(request)
    # lookup subdomain.
    host, path_info, query_string = request.host, request.path_info, request.query_string
    return unless subdomain = @@finder.fetch(request.host)

    # build redirection URL. The redirection target's hostname is the endpoint
    # as defined in the subdomain.

    # returns the URL for a specific port. This url is the URL of the public
    # endpoint of the tunnel. All requests that go there will be routed via
    # the (auto)ssh tunnel to the endpoint.
    #
    # Note that DNS for the domains name (<subdomain>.pipe2.me) resolves to
    # this server (or else the request wouldn't end up here. That means we
    # will redirect to the same server, but to a different port. It is
    # important to keep the name intact, as any SSL certificate in use on the
    # start point must match the name of the request. We do this by using
    # the subdomain's url
    url = subdomain.url
    url += path_info
    url += "?#{query_string}" if query_string.present?
    url
  end
end
