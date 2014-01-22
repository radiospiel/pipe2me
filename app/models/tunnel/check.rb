# Tunnel status check
class Tunnel::Check < ActiveRecord::Base
  belongs_to :tunnel

  validates_format_of :source_ip, :with => /\A(\d+\.){3}\d+\z/
end

module Tunnel::Check::Etest
  def tunnel(options = {})
    options[:token] = "test@pipe2me" unless options.key?(:token)

    tunnel = Tunnel.create! options
    Tunnel.find(tunnel.id)
  end

  def test_check
    assert_nothing_raised {
      tunnel.check! source_ip: "127.0.0.1"
    }
    assert_raise(ActiveRecord::RecordInvalid) {
      tunnel.check!
    }
  end
end
