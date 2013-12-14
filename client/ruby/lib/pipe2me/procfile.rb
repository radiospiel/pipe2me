module Pipe2me::Procfile
  extend self

  # The procfile path
  def path
    "#{Pipe2me::Config.path}/Procfile"
  end

  def write
    File.open(path, "w") do |io|
      Pipe2me::Config.tunnels.each do |name|
        idx = 0

        commands_for(name) do |cmd|
          idx += 1
          io.puts "#{name.split(".", 2).first}-#{idx}: #{cmd.join(" ")}\n"
        end
      end
    end

    UI.success "Wrote #{path}"

    FileUtils.cp "#{File.dirname(__FILE__)}/pipe2me-runner", Pipe2me::Config.path, :verbose => true
    FileUtils.cp "#{File.dirname(__FILE__)}/initscript", Pipe2me::Config.path, :verbose => true
  end

  private

  def commands_for(name)
    info = Pipe2me::Config.tunnel(name)

    name, ports, tunnel = info.values_at :name, :ports, :tunnel
    tunnel_uri = URI.parse(tunnel)

    # verify, and, if needed, fix id_rsa mod (too prevent (some) ssh's
    # from complaining
    id_rsa = File.join Pipe2me::Config.path("tunnels"), name, "id_rsa"
    FileUtils.chmod 0600, id_rsa

    # create a command for each port
    first_port, local_port = info.values_at :port, :local_port
    local_port ||= first_port

    ports.each_with_index do |port, idx|
      UI.info "Forwarding #{tunnel_uri.host}:#{port} => localhost:#{local_port + port - first_port}"
      yield [
        "env", "AUTOSSH_GATETIME=0",
        autossh,
        "-M 0",
        "#{tunnel_uri.user}@#{tunnel_uri.host}",
        "-p #{tunnel_uri.port}",
        "-R 0.0.0.0:#{port}:localhost:#{local_port + port - first_port}",
        "-i #{id_rsa}",
        "-o StrictHostKeyChecking=no",
        "-N"
      ]

      # To allow for switchover between the tunnel endpoint and the next router
      # we need the server to listen on identical ports. If the local port is
      # different from the remote port, we also install another local port
      # forwarder.
      next if port == local_port + port - first_port
      next if %w(localhost 127.0.0.1).include? tunnel_uri.host

      UI.info "Forwarding localhost:#{port} => localhost:#{local_port + port - first_port}"

      # Note that we don't use iptables here, but socat.
      # see http://superuser.com/questions/425694/duplicate-reroute-port-to-another-port
      yield [
        socat, "-d" ,"-d",
        "-lmlocal2",                                                   # logging
        "TCP4-LISTEN:#{port},bind=localhost,su=nobody,fork,reuseaddr",
        "TCP4:localhost:80,bind=localhost"
      ]
    end
  end

  def autossh
    @autossh ||= Installer.which! :autossh
  end

  def socat
    @socat ||= Installer.which! :socat
  end
end
