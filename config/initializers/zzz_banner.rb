if $0 !~ /rake$/

puts <<-BANNER
=== pipe2me #{VERSION} =========================================
ROOT                = #{ROOT.inspect}
TUNNEL_PORTS        = #{TUNNEL_PORTS.inspect}
TUNNEL_DOMAIN       = #{TUNNEL_DOMAIN.inspect}
SSHD.root           = #{SSHD.root.inspect}
SSHD.listen_address = #{SSHD.listen_address.inspect}
DATABASE_URL        = #{DATABASE_URL.inspect}
================================================================
BANNER

end