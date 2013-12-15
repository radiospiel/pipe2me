module Pipe2me::Provisioning
  extend self

  # -- Provisioning -----------------------------------------------------------

  # fetch the provisioning for tunnel \a name, and installs it in the pipe2me
  # directory. This method connects to the server specified in the tunnel
  # configuration.
  def update(name)
    info = Pipe2me::Config.tunnel(name)

    update_item info, "id_rsa"
    update_item info, "id_rsa.pub"
  end

  private

  def update_item(info, item)
    tunnel_url = "#{info[:server]}/subdomains/#{info[:token]}"
    path = File.join Pipe2me::Config.path("tunnels/#{info[:name]}"), item

    File.atomic_write path, HTTP.get!("#{tunnel_url}/#{item}")
  end
end
