if File.exists?("#{VAR}/server.conf")
  load "#{VAR}/server.conf"
else
  TUNNEL_DOMAIN = "pipe2.dev"
  TUNNEL_PORTS = 10000...40000
end
