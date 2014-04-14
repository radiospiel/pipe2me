module StatHat
  module QuickDummy
    def count(name, value = 1)
    end

    def value(name, value)
    end
  end

  module Quick
    PREFIX = STATHAT_PREFIX || "test"
    def count(name, value = 1)
      StatHat::SyncAPI.ez_post_count("#{PREFIX}.#{name}", STATHAT_EMAIL, value)
    end

    def value(name, value)
      StatHat::SyncAPI.ez_post_value("#{PREFIX}.#{name}", STATHAT_EMAIL, value)
    end
  end
end

unless defined?(STATHAT_EMAIL)
  STDERR.puts "To report requests to stathat set the STATHAT_EMAIL and STATHAT_PREFIX entries in var/server.conf"
  StatHat.extend StatHat::QuickDummy
else
  StatHat.extend StatHat::Quick
end
