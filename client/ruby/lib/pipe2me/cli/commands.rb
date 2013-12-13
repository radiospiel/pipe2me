module Pipe2me::CLI
  # short list all tunnels
  def ls(options = {})
    Pipe2me::Config.tunnels.each do |name|
      puts name
    end
  end

  # list all tunnels
  def list(options = {})
    Pipe2me::Config.tunnels.each do |name|
      puts name
      Pipe2me::Config.tunnel(name).each do |k,v|
        puts "  #{k}: #{v}"
      end
    end
  end

  # update provisioning for all tunnels
  def update(options = {})
    Pipe2me::Config.tunnels.each do |name|
      Pipe2me::Provisioning.update name
    end
  end

  # fetch a new pipe2me setup
  def setup(options = {})
    response = HTTP.post! "#{Pipe2me::Config.server}/subdomains", ""
    tunnel = response.parse["subdomain"]

    name, token = tunnel.values_at "name", "token"

    Pipe2me::Config.install_tunnel name, token
    Pipe2me::Provisioning.update name
  end

  def start(options = {})
    Pipe2me::Tunnel.start_all
  end

  # This installs the pipe2me software on Linux and OSX. It also ensures that
  # all dependencies (most notably ssh, autossh) are available,  and that the
  # system is supported. (We support Debian, probably some other Linuxes, and OSX.)
  #
  # Installs the pipe2me init script on Linux. Installs a LaunchAgent on OSX.
  def install(*args)
    # install needed binaries
    Installer.install "ssh", "autossh"

    # install launchagent/init script
    # Installer.install "ssh", "autossh"
  end
end
