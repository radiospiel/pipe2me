class Cache
  attr :ttl

  def initialize(options = {}, &block)
    @thread_current_key = :"Cache:#{object_id}"
    @ttl = options[:ttl] || 60.seconds
    @block = block
  end

  def fetch(key, ttl = self.ttl)
    value, timestamp = cache[key]
    now = Time.now

    if timestamp
      return value if timestamp > now - ttl
      cache.delete key
    end

    if value = @block.call(key)
      cache[key] = [ value, now ]
    end

    value
  end

  private

  def cache
    Thread.current[@thread_current_key] ||= {}
  end
end
