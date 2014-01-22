class Tunnel::Port < ActiveRecord::Base
  SELF = self

  belongs_to :tunnel

  validates_inclusion_of  :protocol, :in => %w(http https imap smtp tcp)

  scope :unused, -> { where(tunnel_id: nil) }

  def self.reserve!(n)
    return if unused.count >= n

    transaction do
      existing_ports = select("port").map(&:port)
      potential_ports = (TUNNEL_PORTS.to_a - existing_ports)

      potential_ports.first(3 * n).each do |port|
        create(port:port)
      end

    end
  end

  def url
    "#{protocol}://#{tunnel.fqdn}:#{port}"
  end

  CHECK_TIMEOUT = 2

  def available?(ip)
    UI.benchmark "Checking #{protocol}://#{ip}:#{port}" do
      begin
        SELF.probe ip, port, protocol
        true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        UI.warn "#{protocol}://#{ip}:#{port}: #{$!.class.name}"
        false
      end
    end
  end

  private

  # Probe timeout set to 1 second + 0 microseconds
  PROBE_TIMEOUT =  timeval = [1, 0].pack("l_2")

  # [fix] - detect whether a proxied port is actually open.
  #         telnet(1) does this.
  def self.probe(ip, port, protocol)
    require "socket"

    # all protocols are TCP based protocols. So no matter what we need a socket
    sock = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
    sock.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
    sock.setsockopt Socket::SOL_SOCKET, Socket::SO_RCVTIMEO, PROBE_TIMEOUT
    sock.connect(Socket.pack_sockaddr_in(port, ip))

    # [todo] - add protocol specific probes.
  ensure
    sock.close if sock
  end
end

module Tunnel::Port::Etest
  def test_port_available
    port = Tunnel::Port.new :port => 55555, protocol: "http"
    assert_equal false, port.available?("127.0.0.1")
    assert_equal false, port.available?("8.8.8.8")
  end
end
