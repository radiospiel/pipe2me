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
end
