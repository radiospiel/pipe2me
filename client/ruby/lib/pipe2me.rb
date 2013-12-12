require_relative "ext/http"
require_relative "ext/sys"
require_relative "ext/tar"
require_relative "ext/ui"

module Pipe2me
  extend self

  attr :server

  def server=(server)
    server = "https://#{server}" unless server =~ /^http(s)?:/
    @server = server
  end

  def server
    @server || config["server"]
  end
end
