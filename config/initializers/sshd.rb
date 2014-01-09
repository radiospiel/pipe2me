require "sshd"

SSHD.root = File.join( "#{VAR}/sshd")
if RACK_ENV == "test"
  SSHD.listen_address = "#{TUNNEL_DOMAIN}:4455"
else
  SSHD.listen_address = "#{TUNNEL_DOMAIN}:4444"
end
