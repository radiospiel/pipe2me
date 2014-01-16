require "wordize"

module Tunnel::FQDN
  extend self

  def generate
    generate = lambda {
      Wordize.wordize + ".#{TUNNEL_DOMAIN}"
    }

    3.times do
      fqdn = generate.call
      return fqdn unless Tunnel.where(fqdn: fqdn).first
    end

    8.times do
      fqdn = generate.call
      return fqdn unless Tunnel.where(fqdn: fqdn).first
      fqdn += "-#{rand(10)}"
      return fqdn unless Tunnel.where(fqdn: fqdn).first
    end

    raise "Cannot generate a new name"
  end
end

module Tunnel::FQDN::Etest
  def test_generate_fqdn
    assert Tunnel::FQDN.generate.ends_with? ".#{TUNNEL_DOMAIN}"
  end
end
