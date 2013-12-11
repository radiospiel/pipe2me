require "wordize"
require "ssh"

class Subdomain < ActiveRecord::Base
  SELF = self
  PORTS = 10000...40000
  PORTS_PER_SUBDOMAIN = 3

  # -- name and port are readonly, once chosen, and are set automatically.
  
  attr_readonly :name, :port
  
  validates_presence_of   :name
  validates_uniqueness_of :name, :on => :create

  validates_inclusion_of  :port, :in => PORTS
  validates_uniqueness_of :port, :on => :create

  before_validation :initialize_defaults

  def initialize_defaults
    self.port = SELF.choose_port unless port?
    self.name = SELF.choose_name unless name?
  end

  # -- ssh keys are generated if missing. (TODO: when?)
  #
  # validates_presence_of :ssh_public_key, :ssh_private_key
  # before_validation :ssh_keygen, :unless => :has_ssh_key?
  # 
  def ssh_keygen!
    return if has_ssh_key?

    self.ssh_public_key, self.ssh_private_key = SSH.keygen(fullname)
    save!
  end
  
  def has_ssh_key?
    ssh_public_key.present? && ssh_private_key.present?
  end

  # -- dynamic attributes -----------------------------------------------------
  
  def fullname
    "#{name}.pipe2.me"
  end
  
  def url(options = {})
    port = options.key?(:port) ? options[:port] : self.port
    if port
      "https://#{fullname}:#{port}"
    else
      "https://#{fullname}"
    end
  end
  
  def ports
    port .. (port + PORTS_PER_SUBDOMAIN - 1)
  end
    
  # -- generate names and ports ----------------------------------------------
  
  def self.choose_name
    3.times do
      name = Wordize.wordize(rand(100000))
      return name unless SELF.where(name: name).first
    end

    8.times do
      name = Wordize.wordize(rand(100000))
      return name unless SELF.where(name: name).first
      name += "-#{rand(10)}"
      return name unless SELF.where(name: name).first
    end

    raise "Cannot find name"
  end
  
  def self.choose_port_sql
    return @choose_port_sql if @choose_port_sql

    conditions = PORTS_PER_SUBDOMAIN.times.map do |idx|
      "port+#{idx} NOT IN (SELECT port FROM subdomains)"
    end
  
    @choose_port_sql = <<-SQL
      SELECT * FROM (
        SELECT port+#{PORTS_PER_SUBDOMAIN} AS port FROM subdomains
          UNION
        SELECT #{PORTS.min} AS port
      )
      WHERE  #{conditions.join(" AND ")}
      ORDER BY port
      LIMIT 1
    SQL
  end
  
  def self.choose_port
    recs = ActiveRecord::Base.connection.select_all(choose_port_sql)

    port = (recs.first && recs.first["port"]) || PORTS.min
    return port if PORTS.cover?(port)
  end
end
