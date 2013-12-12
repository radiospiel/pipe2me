require "fileutils"
module Pipe2me::CLI
  # starts all pipe2.me tunnels by enabling the service.
  def start(options = {})
    info_inc = File.read ".pipe2me/subdomain/info.inc"

    if info_inc =~ /NAME=(.*)/
      name = $1
    end
    ports = []
    if info_inc =~ /PORTS_(\d+)=(.*)/
      ports[$1.to_i]= $2
    end

    UI.warn "name", name
    UI.warn "ports", ports

    id_rsa = ".pipe2me/subdomain/#{name}/id_rsa"

    # -- to prevent (some) sshs from complaining ------------------------------
    FileUtils.chmod 0600, id_rsa

    #UI.warn File.read(id_rsa)

    account = "account"     # TODO: account on tunnel endpoint
    control_port = 4422     # TODO: control port on tunnel endpoint

    # create a proc file
    procfile = ".pipe2me/procfile"
    File.open ".pipe2me/procfile", "w" do |io|
      ports.each do |port|
        command = [
          "autossh",
          "-M 0",
          account,
          "-p #{control_port}",
          "-R 0.0.0.0:#{port}:localhost:#{port}",
          "-i #{id_rsa}",
          "-o StrictHostKeyChecking=no",
          "-N"
        ]
        io.puts "tunnel-#{port}: #{command.join(" ")}"
      end
    end

    UI.warn File.read(procfile)
    Kernel.exec "foreman", "start", "--procfile=#{procfile}", "--root=#{Dir.getwd}"
  end

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
