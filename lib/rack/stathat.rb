require "stathat"

module Rack
  class Stathat

    # @param [Hash] opts a hash of options
    # @option [Symbol] :ez_api_key The stathat ez api key (the email address of the account)
    # @option [Symbol] :ez_api_key The stathat ez api key (the email address of the account)
    def initialize(app, opts = {})
      @app, @opts = app, opts

      @ez_api_key = @opts[:ez_api_key]
      @prefix = @opts[:prefix] || "test"
    end

    attr :ez_api_key, :prefix

    def call(env, &block)
      start_time = Time.now

      status, headers, body = @app.call(env)

      if ez_api_key = self.ez_api_key
        status_group = (status / 100) * 100
        StatHat::API.ez_post_count("#{prefix}.status.#{status_group}", ez_api_key, 1)
        StatHat::API.ez_post_value("#{prefix}.run_time", ez_api_key, Time.now - start_time)
        StatHat::API.ez_post_count("#{prefix}.request", ez_api_key, 1)
      end

      [status, headers, body]
    end
  end
end
