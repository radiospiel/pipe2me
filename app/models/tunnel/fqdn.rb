require "wordize"

module Tunnel::FQDN
  extend self

  def generate(no)
    # expect! no => Fixnum

    generate = lambda { |idx|
      Wordize.wordize(idx) + ".#{TUNNEL_DOMAIN}"
    }

    3.times do
      fqdn = generate.call(no)
      return fqdn unless Tunnel.where(fqdn: fqdn).first
      no += 1
    end

    8.times do
      fqdn = generate.call(no)
      return fqdn unless Tunnel.where(fqdn: fqdn).first
      fqdn += "-#{rand(10)}"
      return fqdn unless Tunnel.where(fqdn: fqdn).first
      no += 1
    end

    raise "Cannot generate a new name"
  end
end

module Tunnel::FQDN::Etest
  def test_generate_fqdn
    assert Tunnel::FQDN.generate(10000).ends_with? ".#{TUNNEL_DOMAIN}"
  end
end
