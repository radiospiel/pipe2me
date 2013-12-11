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

  def self.cache
    Thread.current[:"Subdomain::Redirection::Cache"] ||= {}
  end
  
  def self.cached(key, ttl = 60)
    subdomain, timestamp = cache[key]
    
    if subdomain
      return subdomain if timestamp > Time.now - ttl
      cache.delete key
    end

    if subdomain = yield
      cache[key] = [ subdomain, Time.now ]
    end
    
    subdomain
  end
  
  # construct a redirection target url for a given request 
  def self.url_for(request)
    # lookup subdomain.

    name = request.host.split(".", 2).first
    subdomain = cached name do
      Subdomain.where(name: name).first
    end
    
    return unless subdomain

    # build redirection target URL. Note that the scheme might be tcp, in 
    # which case this method returns a target URL, that might be invalid
    # for most http clients.
    
    host = subdomain.host || request.host
    query_string = "?#{request.query_string}" if request.query_string.present? 
    "#{subdomain.scheme}://#{host}:#{subdomain.port}#{request.path_info}#{query_string}"
  end
end
