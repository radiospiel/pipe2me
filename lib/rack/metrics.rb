require "stathat"

module Rack
  class Metrics

    # @param [Hash] opts a hash of options
    # @option [Symbol] :ez_api_key The stathat ez api key (the email address of the account)
    # @option [Symbol] :ez_api_key The stathat ez api key (the email address of the account)
    def initialize(app, opts = {})
      @app, @opts = app, opts
    end

    def call(env, &block)
      start_time = Time.now

      status, headers, body = @app.call(env)

      status_group = (status / 100) * 100

      unexcepted do
        StatHat.count("status.#{status_group}", 1)
        StatHat.value("run_time", Time.now - start_time)
        StatHat.count("request", 1)
      end

      unexcepted do
        MetricSystem.count("status.#{status_group}", 1)
        MetricSystem.gauge("run_time", Time.now - start_time)
        MetricSystem.count("request", 1)
      end

      [status, headers, body]
    end

    private

    def unexcepted(&block)
      yield
    rescue
      STDERR.puts "[#{$!.class}] Ignoring exception from\n\t" + $!.backtrace.join("\n\t")
    end
  end
end
