require "wordize"
require "ssh"

class Subdomain < ActiveRecord::Base

  # -- configuration ----------------------------------------------------------
  
  PORTS=::PORTS
  PORTS_PER_SUBDOMAIN=::PORTS_PER_SUBDOMAIN

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

  # -- SSH keys ---------------------------------------------------------------
  
  # generate and save ssh keys if missing. 
  def ssh_keygen!
    return if has_ssh_key?

    ssh_public_key, ssh_private_key = SSH.keygen(fullname)
    update_attributes! ssh_public_key: ssh_public_key, ssh_private_key: ssh_private_key
  end

  # does this record has ssh keys?
  def has_ssh_key?
    ssh_public_key.present? && ssh_private_key.present?
  end

  # -- dynamic attributes -----------------------------------------------------
  
  # def fullname
  #   "#{name}.pipe2.me"
  # end
  # 
  # def url(options = {})
  #   port = options.key?(:port) ? options[:port] : self.port
  #   if port
  #     "https://#{fullname}:#{port}"
  #   else
  #     "https://#{fullname}"
  #   end
  # end
  
  # def ports
  #   port .. (port + PORTS_PER_SUBDOMAIN - 1)
  # end
end
