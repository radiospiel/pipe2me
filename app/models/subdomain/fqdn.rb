require "wordize"

module Subdomain::FQDN
  def self.choose
    3.times do
      fqdn = generate
      return fqdn unless Subdomain.where(fqdn: fqdn).first
    end

    8.times do
      fqdn = generate
      return fqdn unless Subdomain.where(fqdn: fqdn).first
      fqdn += "-#{rand(10)}"
      return fqdn unless Subdomain.where(fqdn: fqdn).first
    end

    raise "Cannot choose a new name"
  end

  def self.generate
    Wordize.wordize(rand(100000)) + ".#{TUNNEL_DOMAIN}"
  end
end
