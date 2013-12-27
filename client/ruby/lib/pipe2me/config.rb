require "tmpdir"

module Pipe2me::Config
  extend self

  DEFAULT_PATH = if `whoami`.chomp == "root"
    "/etc/pipe2me"
  else
    File.expand_path("~/.pipe2me")
  end

  attr :path, true

  # Returns a path inside the pipe2me config directory.
  def path(*components)
    path = @path || DEFAULT_PATH
    path = File.join(path, *components)
    FileUtils.mkdir_p path unless File.exist?(path)
    path
  end

  # -- server setting

  attr :server

  def server=(server)
    raise "Missing server" unless server

    server = "https://#{server}" unless server =~ /^http(s)?:/
    @server = server
  end

  def server
    raise "Missing server setting" unless @server
    @server
  end

  # -- Tunnel information -----------------------------------------------------

  def configured_tunnels(*patterns)
    tunnels = Dir.glob("#{path("tunnels")}/*").sort.map do |dirname|
      File.basename(dirname)
    end

    # limit tunnel selection to those matching pattern
    return tunnels if patterns.empty?

    tunnels.select do |tunnel|
      patterns.any? { |pattern| File.fnmatch(pattern, tunnel) }
    end
  end

  # returns an array with the names of all tunnels.
  def tunnels(*patterns)
    tunnels = configured_tunnels(*patterns)

    tunnels.select do |name|
      next true if remote_tunnel?(name)

      info = tunnel(name)
      UI.warn "#{name}: Missing tunnel (at #{info[:server]})"
      false
    end
  end

  # returns all tunnels that exist remotely
  def remote_tunnel?(name)
    info = tunnel(name)
    HTTP.get? "#{info[:server]}/subdomains/#{info[:token]}"
  end

  # returns an info hash about a specific tunnel.
  def tunnel(name)
    raise ArgumentError, "Missing name" unless name
    tunnel_info = parse_info path("tunnels/#{name}"), "info.inc"
    local_info = parse_info path("tunnels/#{name}"), "local.inc"

    tunnel_info.merge(local_info)
  end

  def tunnel_download(name, asset)
    info = tunnel(name)

    remote_basedir = "#{info[:server]}/subdomains/#{info[:token]}"
    local_basedir = path("tunnels/#{info[:fqdn]}")

    url = "#{remote_basedir}/#{asset}"
    path  = "#{local_basedir}/#{asset}"

    File.atomic_write path, HTTP.get!(url)
  end

  def install_file(src, dest)
    return if File.exists?(dest) && File.mtime(src) <= File.mtime(dest)

    FileUtils.mkdir_p File.dirname(dest)

    FileUtils.cp src, dest
    UI.info "Copied #{src} -> #{dest}"
  end

  def tunnel_download_certificate(name)
    info = tunnel(name)

    fqdn = info[:fqdn]

    # -- make sure the openssl subdir exists ----------------------------------

    Pipe2me::Config.path("openssl")
    openssl_conf  = File.join(Pipe2me::Config.path("openssl"), "openssl.conf")
    install_file File.join(File.dirname(__FILE__), "openssl.conf"), openssl_conf

    # -- paths ----------------------------------------------------------------

    remote_basedir = "#{info[:server]}/subdomains/#{info[:token]}"
    local_basedir = path("tunnels/#{info[:fqdn]}")

    privkey_path = "#{local_basedir}/openssl.privkey.pem"
    csr_path = "#{local_basedir}/openssl.csr"
    cert_path = "#{local_basedir}/openssl.pem"

    # -- create privkey and CSR -----------------------------------------------

    unless File.exists?(privkey_path) && File.exists?(csr_path)
      Sys.sys! "openssl",
        "req", "-config", openssl_conf,
        "-new", "-nodes",
        "-keyout", "#{local_basedir}/openssl.privkey.pem",
        "-out", "#{local_basedir}/openssl.csr",
        "-subj", "/C=de/ST=ne/L=Berlin/O=kinko/CN=#{fqdn}",
        "-days", "7300"
    end

    # -- send CSR to server and receive certificate ---------------------------

    unless false && File.exists?(cert_path)
      url = "#{remote_basedir}/openssl.pem"
      certificate = HTTP.post!("#{remote_basedir}/cert.pem", File.read(csr_path), {'Content-Type' =>'text/plain'})
      UI.info "received certificate:\n#{certificate}"

      File.atomic_write cert_path, certificate
    end
  end

  private

  def parse_info(*path)
    path = File.join *path
    ShellFormat.parse File.read(path)
  end

  public

  def install_tunnel(server_info, local_info)
    name = server_info[:fqdn] || raise(ArgumentError, "Missing :fqdn information")

    path = self.path("tunnels/#{name}")
    File.atomic_write File.join(path, "info.inc"), ShellFormat.dump(server_info)
    File.atomic_write File.join(path, "local.inc"), ShellFormat.dump(local_info)

    name
  end

  def uninstall_tunnel(name)
    path = self.path("tunnels/#{name}")
    FileUtils.rm_rf path
  end
end
