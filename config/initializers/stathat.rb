require "stathat"

module StatHat
  module QuickDummy
    def count(name, value = 1)
    end

    def value(name, value)
    end
  end

  module SwitchableAPI
    attr :api, true
  end
  extend SwitchableAPI

  module Quick
    if defined?(STATHAT_PREFIX)
      PREFIX = STATHAT_PREFIX || "test"
    else
      PREFIX = "test"
    end

    def count(name, value = 1)
      api.ez_post_count("#{PREFIX}.#{name}", STATHAT_EMAIL, value)
    end

    def value(name, value)
      api.ez_post_value("#{PREFIX}.#{name}", STATHAT_EMAIL, value)
    end
  end
end

StatHat.api = StatHat::SyncAPI

unless defined?(STATHAT_EMAIL)
  STDERR.puts "To report requests to stathat set the STATHAT_EMAIL and STATHAT_PREFIX entries in var/server.conf"
  StatHat.extend StatHat::QuickDummy
else
  StatHat.extend StatHat::Quick
end
