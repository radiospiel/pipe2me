module Pipe2me::CLI
  banner "delete one or more tunnel"
  def rm(arg, *args)
    Pipe2me::Config.configured_tunnels(arg, *args).each do |name|
      Pipe2me::Config.uninstall_tunnel name
      UI.success "uninstalled tunnel", name
    end
  end

  banner "short list all tunnels"
  def ls(*args)
    Pipe2me::Config.configured_tunnels(*args).each do |name|
      puts name
    end
  end

  banner "list all accessible tunnels"
  def list(*args)
    Pipe2me::Config.tunnels(*args).each do |name|
      puts name
      Pipe2me::Config.tunnel(name).each do |k,v|
        puts "  #{k}: #{v}"
      end
    end
  end

  banner "delete all stale tunnels"
  def clean(*args)
    Pipe2me::Config.configured_tunnels(*args).each do |name|
      next if Pipe2me::Config.remote_tunnel?(name)
      Pipe2me::Config.uninstall_tunnel name
      UI.success "uninstalled tunnel", name
    end
  end

  banner "update provisioning for all tunnels"
  def update(*args)
    Pipe2me::Config.tunnels(*args).each do |name|
      Pipe2me::Config.tunnel_download name, "id_rsa"
      Pipe2me::Config.tunnel_download name, "id_rsa.pub"
      Pipe2me::Config.tunnel_download_certificate name

      UI.info "Updating", name
    end
  end

  banner "fetch a new tunnel setup"
  option :server, "Use pipe2.me server on that host", :default => "https://pipe2.me:5000"
  option :auth, "pipe2.me auth token",  :type => String, :required => true
  option :protocols, "protocol names, e.g. 'http,https,imap'", :type => String, :default => "https"
  option :local_ports, "local ports, one per protocol", :type => String
  def setup
    Pipe2me::Config.server = options[:server]

    # [todo] escape auth option
    response = HTTP.post! "#{Pipe2me::Config.server}/subdomains/#{options[:auth]}",
      "protocols" => options[:protocols]

    server_info = ShellFormat.parse(response)

    Pipe2me::Config.install_tunnel server_info,
      server:       Pipe2me::Config.server,
      local_ports:  options[:local_ports]

    update server_info[:fqdn]
    puts server_info[:fqdn]
  end

  banner "Start tunnels"
  def start
    Pipe2me::Procfile.write Pipe2me::Config.tunnels
    Dir.chdir Pipe2me::Config.path
    UI.debug "chdir into", Pipe2me::Config.path
    Kernel.exec "./pipe2me-runner"
  end

  banner "Start all tunnels and test servers"
  def test
    Pipe2me::Procfile.write Pipe2me::Config.tunnels, test: true
    Dir.chdir Pipe2me::Config.path
    UI.debug "chdir into", Pipe2me::Config.path
    Kernel.exec "./pipe2me-runner"
  end

  # Verify installation
  banner "Install init.d script"
  def install
    # install needed binaries
    ::Installer.install "ssh"

    Pipe2me::Procfile.write      # rebuild procfile
  end
end
