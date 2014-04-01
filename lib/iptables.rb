module IPTables
  extend self

  # -- setup rules for tunnels -------------------------------------------.....

  public

  def setup
    tunnels = Tunnel.all.each do |tunnel|
      setup_tunnel(tunnel)
    end
  end

  private

  def setup_tunnel(tunnel)
    ports = tunnel.ports.map(&:port)
    return if ports.empty?

    ports.sort!
    name = "PIPE2ME_TUNNEL_#{ports.first}"

    # create an iptables chain with that name if there is none yet
    Sys.sudo :iptables, "-N", name

    # create iptables rule if there is none yet
    rule = "INPUT -p tcp -j #{name} -m multiport --dports #{ports}".split(/\s+/)
    unless Sys.sudo :iptables, "-C", *rule
      Sys.sudo! :iptables, "-A", *rule
    end
  end

  # -- fetch traffic report ---------------------------------------------------

  public

  def report
    traffic_total = 0

    fetch_report.each do |name, traffic|
      next unless traffic != 0

      # -- determine tunnel for that rule -------------------------------------
      min_port = name.gsub(/.*\D(\d+)$/, "\\1").to_i
      tunnel = Tunnel.includes(:ports).where("tunnel_ports.port" => min_port).first
      # next unless tunnel

      # -- report traffic to tunnel -------------------------------------------
      # tunnel.report_traffic traffic

      # -- determine tunnel for that rule -------------------------------------
      traffic_total += traffic
    end

    send_to_stathat :traffic => traffic_total
  end

  private

  def fetch_report
    report = Sys.sudo! :iptables, "-L", "INPUT", "-n", "-x", "-v"
    report.each_line.inject({}) do |hsh, line, idx|
      next hsh if line !~ /PIPE2ME/

      parts = line.split(/\s+/)
      hsh.update parts[3] => parts[2].to_i
    end
  end

  def send_to_stathat(options)
    unless defined?(STATHAT_EMAIL)
      STDERR.puts "To report requests to stathat set the STATHAT_EMAIL and STATHAT_PREFIX entries in var/server.conf"
      return
    end
    prefix = STATHAT_PREFIX || "test"

    require "stathat"

    options.each do |key, value|
      StatHat::SyncAPI.ez_post_count("#{prefix}.#{key}", STATHAT_EMAIL, value)
    end

    UI.warn "reported #{prefix}", options
  end
end
