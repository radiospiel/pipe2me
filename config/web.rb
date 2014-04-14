# Additional configuration for web processes.

def open_socket(path, retries = 4)
  while retries > 0
    begin
      return UNIXSocket.new(path)
    rescue Errno::ECONNREFUSED, Errno::ENOENT
      # STDERR.puts "#{$!}"
    end

    retries -= 1
  end

  sleep 0.1

  STDERR.puts "Cannot connect to #{path}; ignoring metric data"
  return STDOUT
end

MetricSystem.target = open_socket(METRIC_SYSTEM_SOCKET)
