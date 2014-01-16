class Tunnel::Port < ActiveRecord::Base
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
end

