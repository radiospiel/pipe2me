module Pipe2me::CLI
  # starts all pipe2.me tunnels by enabling the service.
  def enable(options = {})
    puts "enable"
  end

  # stops all pipe2.me tunnels by disabling the service.
  def disable(options = {})
    puts "disable"
  end

  # print the local pipe2me status (enabled/disabled, local ports
  # and connections.
  def status(options = {})
    puts "status"
  end
end
