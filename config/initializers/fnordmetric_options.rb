__END__

require "fnordmetric"

module FnordMetric
  def self.event(*args, &block)
    @api ||= API.new
    @api.event(*args, &block)
  end
end

root=File.expand_path "#{File.dirname(__FILE__)}/../.."

FnordMetric.options = {
  redis_socket: "unix:///#{root}/var/sockets/redis.socket",  # Your redis server address. default is redis://localhost:6379.
  redis_prefix: "fnordmetric",                              # FnordMetric prefixes all keys it saves in redis.
                                                            # The default prefix is fnordmetric.
  default_flush_interval: 10,                               # Default gauge flush interval, default value is 10 seconds.
  enable_active_users:    false,                             # Enable the active users plugin, default value is true.
  enable_gauge_explorer:  true,                             # Enable the gauge explorer plugin, default value is true.
  event_queue_ttl:        120,                              # This controls how long events are allowed to stay in the
                                                            # internal queue before being processed (events that are not
                                                            # processed in this timeframe are lost). The default is 2 minutes.
  event_data_ttl:         30 * 24 * 3600,                   # This controls how long event data is kept in redis.
                                                            # You can use this to drastically lower redis memory usage.
                                                            # The default is 30 days.
  session_data_ttl:       30 * 24 * 3600,                   # This controls how long user sessions are saved in redis
                                                            # (this option is void if you disable the active_users plugin).
                                                            # The default is 30 days.
  http_websocket_only:    false,                             # If set to true, the http server (thin) will accept
                                                            # websocket connections, but will not start the web interface.

  inbound_stream: false,
  web_interface:  ["0.0.0.0", FNORDMETRIC_PORT]
}
