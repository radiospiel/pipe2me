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
