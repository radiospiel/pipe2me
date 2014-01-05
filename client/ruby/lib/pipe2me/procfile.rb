module Pipe2me::Procfile
  extend self

  # The procfile path
  def path
    "#{Pipe2me::Config.path}/Procfile"
  end

  def write(tunnels, options = {})
    procfile = ""

    tunnels.each do |fqdn|
      idx = 0
      commands_for(fqdn) do |cmd|
        idx += 1
        procfile << "#{fqdn.split(".", 2).first}-#{idx}: #{cmd.join(" ")}\n"
      end

      next unless options[:test]

      idx = 0
      tests_for(fqdn) do |cmd|
        idx += 1
        procfile << "#{fqdn.split(".", 2).first}-echo-#{idx}: #{cmd.join(" ")}\n"
      end
    end

    File.atomic_write(path, procfile)

    UI.success "Wrote #{path}"
    UI.info procfile

    FileUtils.cp "#{File.dirname(__FILE__)}/pipe2me-runner", Pipe2me::Config.path #, :verbose => true
    FileUtils.cp "#{File.dirname(__FILE__)}/initscript", Pipe2me::Config.path #, :verbose => true
  end

  private

  def tests_for(name)
    info = Pipe2me::Config.tunnel(name)

    # The client comes with a number of test servers, that more or less echo their input.
    # They live in #{here}/echo.
    here = File.dirname(__FILE__)

    path, urls, local_ports = info.values_at :path, :urls, :local_ports
    urls.zip(local_ports || []).each do |url, local_port|
      uri = URI.parse(url)
      local_port ||= uri.port

      cmd = case uri.scheme
      when "https"  then "env PORT=#{local_port} PIPE2ME_TUNNEL=#{path} SSL=1 #{here}/echo/http"
      when "http"   then "env PORT=#{local_port} #{here}/echo/http"
      else
        UI.warn "No test server available for scheme", uri.scheme
      end

      yield [ cmd ] if cmd
    end
  end

  def commands_for(name)
    info = Pipe2me::Config.tunnel(name)

    # verify, and, if needed, fix id_rsa mod (too prevent (some) ssh's
    # from complaining
    id_rsa = File.join Pipe2me::Config.path("tunnels"), info[:fqdn], "id_rsa"
    FileUtils.chmod 0600, id_rsa

    tunnel, urls, local_ports = info.values_at :tunnel, :urls, :local_ports
    tunnel_uri = URI.parse(tunnel)

    # create a command for each port
    urls.zip(local_ports || []).each do |url, local_port|
      port = URI.parse(url).port
      local_port ||= port
      UI.info "Forwarding #{tunnel_uri.host}:#{port} => localhost:#{local_port}"

      yield [
        "env", "AUTOSSH_GATETIME=0",
        autossh,
        "-M 0",
        "#{tunnel_uri.user}@#{tunnel_uri.host}",
        "-p #{tunnel_uri.port}",
        "-R 0.0.0.0:#{port}:localhost:#{local_port}",
        "-i #{id_rsa}",
        "-o StrictHostKeyChecking=no",
        "-N"
      ]

      # To allow for switchover between the tunnel endpoint and the next router
      # we need the server to listen on identical ports. If the local port is
      # different from the remote port, we also install another local port
      # forwarder.
      next if local_port == port
      next if %w(localhost 127.0.0.1).include?(tunnel_uri.host)

      UI.info "Forwarding localhost:#{port} => localhost:#{local_port}"

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
