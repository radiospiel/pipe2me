module Tunnel::Status
  def self.included(other)
    other.instance_eval do
      scope :online,  lambda { where "ssh_public_key IS NOT NULL AND expires_at > ?", Time.now }
      scope :offline, lambda { where "ssh_public_key IS NULL OR expires_at <= ?", Time.now }
      scope :ancient, lambda { where "(ssh_public_key IS NULL AND updated_at < ?) OR (expires_at <= ?)", Time.now - 1.week, Time.now - 1.week }
    end
    other.extend ClassMethods
  end

  def online?
    ssh_public_key && expires_at > Time.now
  end

  module ClassMethods
    # check: verify whether or not the online? status matches the stored
    # online atus. When needed, yield and change the status.
    def check(&block)
      transaction do
        onlined  = online.where("status != ?", "online").update_all status: "online"
        offlined = offline.where("status != ?", "offline").update_all status: "offline"

        return false if onlined == 0 && offlined == 0

        yield if block
      end

      true
    end
  end
end

module Tunnel::Status::Etest
  def test_check_wo_block
    Tunnel.update_all status: ""

    # the first check should yield
    assert Tunnel.check

    # the next check should not yield
    assert !Tunnel.check
  end

  def test_check
    Tunnel.update_all status: ""

    yielded = false
    r = Tunnel.check { yielded = true }
    assert yielded
    assert r

    # the next check should not yield

    yielded = false
    r = Tunnel.check { yielded = true }
    assert !yielded
    assert !r
  end
end
