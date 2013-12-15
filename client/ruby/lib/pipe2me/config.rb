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

  # returns an array with the names of all tunnels.
  def tunnels(*patterns)
    tunnels = Dir.glob("#{path("tunnels")}/*").sort.map do |dirname|
      File.basename(dirname)
    end
    return tunnels if patterns.empty?

    tunnels.select do |tunnel|
      patterns.any? do |pattern| File.fnmatch(pattern, tunnel) end
    end
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

    remote_base = "#{info[:server]}/subdomains/#{info[:token]}"
    local_base = path("tunnels/#{info[:name]}")

    url = "#{remote_base}/#{asset}"
    path  = "#{local_base}/#{asset}"
    UI.debug "#{url} => #{path}"
    File.atomic_write path, HTTP.get!(url)
  end

  private

  def parse_info(*path)
    path = File.join *path
    ShellFormat.parse File.read(path)
  end

  public

  def install_tunnel(server_info, local_info)
    name = server_info[:name] || raise(ArgumentError, "Missing :name information")

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
