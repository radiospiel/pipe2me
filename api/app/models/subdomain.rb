require "sys"

#
# A Subdomain object models a single subdomain registration. Each subdomain
# manages a number of ports. These ports are assigned by the server in the
# TUNNEL_PORTS range. Subdomain manages a number of tunnels on different ports.
#
# The request for a subdomain contains a number of services, like http,
# https, etc. These service settings are used to determine whether the
# service running on the machine tunnelled to is alive, and whether all
# services are accessible directly - which allows to redirect traffic to
# that machine via DNS. These settings are returned by the *ports* attribute.
#
# The subdomain has openssh identity tokens in *ssh_public_key* and
# *ssh_private_key*, which can be used to establish the tunnels via OpenSSH,
# and an OpenSSL certificate in *openssl_certificate*.

# Other attributes:
#
# - a subdomain is identified by a *token* - a randomly generated string.
# - a subdomain has a *fqdn*
# - a subdomain has a tunnel *endpoint*. This is the hostname which offers
#   the publicly available ports for the services.
# - a subdomain has ssl identity tokens in *ssh_public_key* and *ssh_private_key*.
# - a subdomain has an *openssl_certificate*, which  ssl identity tokens in *ssh_public_key* and *ssh_private_key*.

#
class Subdomain < ActiveRecord::Base
  # -- name and port are readonly, once chosen, and are set automatically -----

  attr_readonly :fqdn, :protocols

  validates_uniqueness_of :fqdn, :on => :create
  validates_presence_of   :fqdn, :on => :create

  # -- the target host --------------------------------------------------------

  # This is the tunnel target hostname. This entry is useful to define
  # different tunnel targets based on some criteria, e.g. the region.

  # -- set default values -----------------------------------------------------

  before_validation :initialize_defaults

  def initialize_defaults
    require_relative "subdomain/fqdn"

    self.token = SecureRandom.random_number(1 << 128).to_s(36) unless token?
    self.fqdn = FQDN.choose unless fqdn?
  end

  # -- ports ------------------------------------------------------------------

  require_relative "subdomain/port"

  attr :protocols, true

  has_many :ports, :class_name => "::Subdomain::Port", :dependent => :destroy

  # Note: assign_ports must be run after the subdomain is created! Otherwise
  # when a newly assigned ports gets assigned to this subdomain it gets not
  # marked as assigned (by setting its subdomain_id) and will be reassigned
  # for the next protocol.
  after_create :assign_ports

  # The protocols attribute contains a list of protocols.
  def assign_ports
    protocols = self.protocols || []
    return if protocols.empty?

    Port.reserve! protocols.count

    protocols.each do |protocol|
      port = Port.unused.first
      raise "Cannot reserve port for '#{protocol}' protocol" unless port
      port.update_attributes! protocol: protocol
      self.ports << port
    end
  end

  # -- dynamic attributes -----------------------------------------------------

  def urls(protocol = nil)
    ports = self.ports
    ports = ports.where(protocol: protocol) if protocol
    ports.map(&:url)
  end

  # The private tunnel URL. This is where the client connects to, usually via
  # autossh, to start the tunnel(s).

  def tunnel_private_url
    "ssh://#{SSHD.user}@#{SSHD.listen_address}"
  end

  # -- OpenSSL cerificate -----------------------------------------------------

  def openssl_certgen!
    return if openssl_certificate?

    Sys.sys! "#{ROOT}/ca/mk-certificate", fqdn
    openssl_certificate = File.read "#{ROOT}/var/openssl/certs/#{fqdn}.pem"
    update_attributes! :openssl_certificate => openssl_certificate
  end

  def openssl_sign_certificate!(csr)
    tmpfile = Tempfile.new("#{fqdn}.csr")
    tmpfile.write csr
    tmpfile.close

    Sys.sys! "#{ROOT}/ca/sign-certificate", fqdn, tmpfile.path
    openssl_certificate = File.read "#{ROOT}/var/openssl/certs/#{fqdn}.pem"
    update_attributes! :openssl_certificate => openssl_certificate

    tmpfile.unlink                            # deletes the temp file
  rescue
    tmpfile.close! rescue nil                 # close and deletes the temp file
    raise
  end

  # -- SSH keys ---------------------------------------------------------------

  scope :with_ssh_keys, -> { where "ssh_public_key IS NOT NULL " }
  scope :without_ssh_keys, -> { where "ssh_public_key IS NULL " }

  # generate and save ssh keys if missing.
  def ssh_keygen!
    return if ssh_public_key.present? && ssh_private_key.present?

    require "sshd"

    ssh_public_key, ssh_private_key = SSHD.keygen(fqdn)
    update_attributes! ssh_public_key: ssh_public_key, ssh_private_key: ssh_private_key
    SSHD.write_authorized_keys
  end
end

module Subdomain::Etest
  def subdomain(options = {})
    subdomain = Subdomain.create! options
    Subdomain.find(subdomain.id)
  end

  def test_single_protocol
    subdomain = self.subdomain protocols: %w(http)
    assert_equal(subdomain.ports.count, 1)
  end

  def test_multiple_protocols
    subdomain = self.subdomain protocols: %w(http https)
    assert_equal(subdomain.ports.count, 2)

    url_protocols = subdomain.urls.map { |url| URI.parse(url).scheme }
    assert_equal(url_protocols, %w(http https) )
  end
end
