module Pipe2me::Provisioning
  extend self

  # -- Provisioning -----------------------------------------------------------

  # fetch the provisioning for tunnel \a name, and installs it in the pipe2me
  # directory. This method connects to the server specified in the tunnel
  # configuration.
  def update(name)
    info = Pipe2me::Config.tunnel(name)

    response = HTTP.get! "#{info[:server]}/subdomains/#{info[:token]}.tar"
    install_response(response)

    UI.debug "#{name}: Received provisioning #{response.bytesize} bytes"
  end

  private

  # unpacks and installs the tunnel response from the server. This method
  # usually overrides the "info.inc" file.
  def install_response(response)
    tunnels = Pipe2me::Config.path("tunnels")

    Tar.extract StringIO.new(response) do |path, data|
      next if path == "subdomain/info.inc"

      target_path = File.join tunnels, path.gsub(/^subdomain\//, "")
      FileUtils.mkdir_p File.dirname(target_path)

      File.open(target_path, "w") do |io|
        io.write data
      end
    end
  end
end
