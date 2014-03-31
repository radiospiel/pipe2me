namespace :iptables do
  task :setup do
    tunnels = Tunnel.all.each do |tunnel|
      ports = tunnel.ports.map(&:port).sort
      next if ports.empty?
      ports = ports.join(",")
      rule = "PIPE2ME_TUNNEL#{tunnel.id}"
      Sys.sys! "sbin/iptables_setup_tunnel", ports, rule
    end
  end
end
