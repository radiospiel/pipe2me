puts <<-BANNER
=== pipe2me #{VERSION} =========================================
ROOT                = #{ROOT.inspect}
TUNNEL_PORTS        = #{TUNNEL_PORTS.inspect}"
SSHD.root           = #{SSHD.root.inspect}
SSHD.listen_address = #{SSHD.listen_address.inspect}
DATABASE_URL        = #{DATABASE_URL.inspect}
================================================================
BANNER
