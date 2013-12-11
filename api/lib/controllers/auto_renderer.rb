require "sinatra/json"
require "sinatra/shell"
require "sinatra/tar"

class Controllers::Base
  helpers Sinatra::JSON
  helpers Sinatra::Shell
  helpers Sinatra::Tar

  # TODO: make this a middleware

  before do
    ext = File.extname(request.url)
    next unless mime_type = Rack::Mime::MIME_TYPES[ext]

    request.accept.unshift Sinatra::Request::AcceptEntry.new(mime_type)
    request.path_info = request.path_info[0 ... -ext.length]
  end

  RENDERER_BY_FORMAT = {
    "application/x-tar"   => :tar,
    "application/x-shell" => :shell,
    "application/x-sh"    => :shell,
    "application/json"    => :json
  }

  attr :default_renderer, true

  helpers do
    def auto_renderer
      RENDERER_BY_FORMAT[request.accept.first.to_str] || self.default_renderer
    end

    def render(*args)
      if renderer = self.auto_renderer
        self.send renderer, *args
      elsif (2..4).cover?(args.length)
        super
      else
        raise "Cannot find renderer for format #{request.accept.first.to_str}"
      end
    end
  end

  after do
    headers["Content-Type"] ||= (accept = request.accept.first) && accept.to_str
  end
end
