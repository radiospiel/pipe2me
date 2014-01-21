module Tunnel::Token
end

require_relative "token/parser"

# A token is an object which allows to create a tunnel or to extend
# a tunnel's lifetime.
module Tunnel::Token
  SELF = self

  def self.included(base)
    # base.before_validation :apply_token
    base.validates_presence_of :expires_at
  end

  def token=(token)
    return if token && self.token == token

    attrs = Parser.all[token] || { invalid: true }

    attrs.each do |key, value|
      # apply values
      case key
      when :lifespan
        self.expires_at = (self.expires_at || Time.now) + value
        next
      end

      case key
      when :max_ports
        raise "Too many ports" unless ports.count <= value
      when :extend
        next if value
        raise "This token is valid for new tunnels only" unless new_record?
      when :unique
        next unless value
        raise "This token can be used only once" if Tunnel.where(token: token).first
      else
        raise "Invalid or missing token: #{token.inspect}"
      end
    end

    super token
  end

  private

  def invalid_token?
    errors.has_key?(:token)
  end
end

module Tunnel::Token::Etest
  if defined?(Tunnel::Etest)
    include Tunnel::Etest
  end

  T = Tunnel

  def test_token_is_needed
    assert_raise(RuntimeError) {
      self.tunnel protocols: %w(http), token: nil
    }
  end

  def test_test_token_goes_offline
    require "timecop"

    # A tunnel is online only if a ssh_public_key is set. For this test
    # a fake value will do.
    tunnel = self.tunnel protocols: %w(http), ssh_public_key: "fake_ssh_public_key"
    assert_equal true, tunnel.online?

    Timecop.travel 5.minutes do
      assert_equal false, tunnel.online?
    end
  end

  def test_token_port_limit
    assert_raise(RuntimeError) {
      self.tunnel protocols: %w(http https tcp tcp), token: nil
    }
  end

  def test_token_update
    require "etest_helper"

    tunnel = self.tunnel protocols: %w(http)
    assert_equal(tunnel.ports.count, 1)

    # updating with TEST_TOKEN does nothing
    tunnel.update_attributes! token: "test@pipe2me"

    # updating with REVIEW_TOKEN raises exception: this token cannot
    # be used to update an existing record
    assert_raise(RuntimeError) {
      tunnel.update_attributes! token: "review@pipe2me"
    }

    assert_raise(RuntimeError) {
      tunnel.token = "review@pipe2me"
    }
  end

  def test_parse_token
    test_token = Tunnel::Token::Parser.all["test@pipe2me"]
    assert_equal test_token, max_ports: 6, lifespan: 180, extend: false, unique: false
  end
end
