module Pipe2me::CLI
  banner "delete one or more tunnel"
  def rm(arg)
    Pipe2me::Config.tunnels(arg).each do |name|
      Pipe2me::Config.uninstall_tunnel name
    end
  end

  banner "short list all tunnels"
  def ls(*args)
    Pipe2me::Config.tunnels(*args).each do |name|
      puts name
    end
  end

  banner "list all tunnels"
  def list(*args)
    Pipe2me::Config.tunnels(*args).each do |name|
      puts name
      Pipe2me::Config.tunnel(name).each do |k,v|
        puts "  #{k}: #{v}"
      end
    end
  end

  banner "update provisioning for all tunnels"
  def update
    Pipe2me::Config.tunnels.each do |name|
      Pipe2me::Provisioning.update name
    end
  end

  banner "fetch a new tunnel setup"
  option :server, "Use pipe2.me server on that host", :default => "https://pipe2.me:5000"
  option :auth, "pipe2.me auth token",  :type => String, :required => true
  option :port, "localhost port number", :default => 33411
  def setup
    Pipe2me::Config.server = options[:server]

    response = HTTP.post! "#{Pipe2me::Config.server}/subdomains", ""
    tunnel = response.parse["subdomain"]

    name, token = tunnel.values_at "name", "token"

    Pipe2me::Config.install_tunnel name, token
    Pipe2me::Provisioning.update name
  end

  banner "Start tunnels"
  def start
    Pipe2me::Tunnel.start_all
  end

  # This installs the pipe2me software on Linux and OSX. It also ensures that
  # all dependencies (most notably ssh, autossh) are available,  and that the
  # system is supported. (We support Debian, probably some other Linuxes, and OSX.)
  #
  # Installs the pipe2me init script on Linux. Installs a LaunchAgent on OSX.
  def install
    # install needed binaries
    Installer.install "ssh", "autossh"

    # install launchagent/init script
    # Installer.install "ssh", "autossh"
  end

  banner "Export init.d scripts"
  def export(fmt="initscript")
    Pipe2me::Tunnel.export "initscript"
  end
end
