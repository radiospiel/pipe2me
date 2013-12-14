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

  private

  def parse_info(*path)
    path = File.join *path

    arrays = {}

    File.readlines(path).inject({}) do |hsh, line|
      key, value = line.split(/\s*=\s*/, 2)
      value.gsub!(/\s*$/, "")
      value = Integer(value) rescue value

      if key =~ /^([^_]+)_(\d+)$/
        ary = arrays[$1] || []
        ary[$2.to_i] = value
        key, value = $1, ary
      end

      hsh.update key.downcase.to_sym => value
    end
  end

  public

  # installs a new tunnel. The argument is the tunnel setting as received
  # from the control server. This method does not fetch or install the
  # provisioning files.
  def install_tunnel(name, token, local_info)
    path = self.path("tunnels/#{name}")

    File.open "#{path}/info.inc", "w" do |io|
      io.puts "NAME=#{name}"
      io.puts "TOKEN=#{token}"
    end

    File.open "#{path}/local.inc", "w" do |io|
      local_info.each do |key, value|
        io.puts "#{key.to_s.upcase}=#{value}"
      end
    end
  end

  def uninstall_tunnel(name)
    path = self.path("tunnels/#{name}")
    FileUtils.rm_rf path
  end
end
