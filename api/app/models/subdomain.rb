require "wordize"
require "ssh"

class Subdomain < ActiveRecord::Base
  # A subdomain has these attributes:
  #
  # An auth token for this subdomain
  # t.string  :token
  #
  # The full name of the subdomain, e.g. "pink-pony.pipe2.me".
  # t.string  :name
  #
  # The hostname of the subdomain's endpoint. A typical endpoint might be
  # "eu.pipe2.me". The endpoint will be used as the CNAME for DNS based
  # redirection to the tunnel, if the start point is not publicly accessible.
  #
  # t.string :endpoint
  #
  # The scheme of the subdomain at port :port. This can be http
  # or https, and is used to verify whether a client is accessible.
  # t.string  :scheme, default: "http"
  #
  # The first port number of the subdomain
  # t.integer :port
  #
  # The private and public SSH key
  # t.text    :ssh_public_key
  # t.text    :ssh_private_key

  # -- name and port are readonly, once chosen, and are set automatically -----

  attr_readonly :name, :port

  validates_presence_of   :name, :on => :create
  validates_uniqueness_of :name, :on => :create

  validates_inclusion_of  :port, :on => :create, :in => PORTS
  validates_uniqueness_of :port, :on => :create

  # -- the target host --------------------------------------------------------

  # This is the tunnel target hostname. This entry is useful to define
  # different tunnel targets based on some criteria, e.g. the region.

  # The scheme for the target host.
  validates_inclusion_of  :scheme, :in => %w(http https tcp)

  # -- set default values -----------------------------------------------------

  before_validation :initialize_defaults

  def initialize_defaults
    require_relative "subdomain/builder"

    self.port = Builder.choose_port unless port?
    self.name = Builder.choose_name unless name?
    self.token = Builder.choose_token unless token?
  end

  # -- find by token or raise RecordNotFound. ---------------------------------

  def self.find_by_token(token)
    where(token: token).first ||
      raise(ActiveRecord::RecordNotFound, "Couldn't find Subdomain with token #{token.inspect}")
  end

  # -- SSH keys ---------------------------------------------------------------

  # generate and save ssh keys if missing.
  def ssh_keygen!
    return if has_ssh_key?

    ssh_public_key, ssh_private_key = SSH.keygen(name)
    update_attributes! ssh_public_key: ssh_public_key, ssh_private_key: ssh_private_key
  end

  # does this record has ssh keys?
  def has_ssh_key?
    ssh_public_key.present? && ssh_private_key.present?
  end

  # -- dynamic attributes -----------------------------------------------------

  def url(options = {})
    port = options[:port] || self.port
    "#{scheme}://#{name}:#{port}"
  end

  def ports
    (port .. (port + PORTS_PER_SUBDOMAIN - 1)).to_a
  end

  # The private tunnel URL. This is where the client connects to, usually via
  # autossh, to start the tunnel(s).

  def tunnel_private_url
    "ssh://#{TUNNEL_USER}@#{TUNNEL_CONTROL_PORT}"
  end
end
