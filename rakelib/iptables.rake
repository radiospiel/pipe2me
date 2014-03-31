# iptables code. Works only on linux, and requires "sudo /sbin/iptables" to
# run without a password.
namespace :iptables do
  task :setup do
    tunnels = Tunnel.all.each do |tunnel|
      ports = tunnel.ports.map(&:port).sort
      next if ports.empty?
      rule = "PIPE2ME_TUNNEL_#{ports.first}"
      ports = ports.join(",")
      Sys.sys! "sbin/iptables_setup_tunnel", ports, rule
    end
  end

  task :report do
    stats = system("sbin/iptables_report")

    traffic_total = 0
    stats.lines.each do |line|
      tunnel, traffic = line.split(":")
      traffic = traffic.to_i

      # [todo] store traffic by tunnel
      traffic_total += traffic
    end

    UI.success "traffic_total: #{traffic_total}"

    # -- reporting traffic to stathat --
    unless defined?(STATHAT_EMAIL)
      STDERR.puts "To report requests to stathat set the STATHAT_EMAIL and STATHAT_PREFIX entries in var/server.conf"
      next
    end

    prefix = STATHAT_PREFIX || "test"
    StatHat::API.ez_post_value("#{prefix}.traffic", STATHAT_EMAIL, traffic_total)
  end
end
