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
  option :port, "localhost port number", :type => Integer
  def setup
    Pipe2me::Config.server = options[:server]

    # TODO: escape options
    response = HTTP.post! "#{Pipe2me::Config.server}/subdomains/#{options[:auth]}", ""
    tunnel = response.parse["subdomain"]

    name, token, url = tunnel.values_at "name", "token", "url"

    local_port = options[:port] || URI.parse(url).port

    Pipe2me::Config.install_tunnel name, token, :server => Pipe2me::Config.server, :local_port => local_port
    Pipe2me::Provisioning.update name

    UI.success "[#{name}] Configured tunnel #{url} => localhost:#{local_port}"
    UI.info "[#{name}] Remember to restart the pipe2me service"

    puts name
  end

  banner "Start tunnels"
  def start
    Pipe2me::Tunnel.start_all
  end

  # Verify installation
  banner "Install init.d script"
  def install
    # install needed binaries
    ::Installer.install "ssh"

    Pipe2me::Procfile.write      # rebuild procfile
  end
end
