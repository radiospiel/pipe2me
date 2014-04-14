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

      # -- report traffic per tunnel ------------------------------------------
      tunnel.report_traffic traffic

      # -- determine tunnel for that rule -------------------------------------
      traffic_total += traffic
    end

    Tunnel.report_traffic_total traffic_total
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

  public

  def fake
    traffic_total = 0
    Tunnel.all.each do |tunnel|
      traffic = tunnel.id
      tunnel.report_traffic traffic
      traffic_total += traffic
    end

    Tunnel.report_traffic_total traffic_total
  end
end
