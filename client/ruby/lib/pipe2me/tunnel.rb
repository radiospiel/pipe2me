module Pipe2me::Tunnel
  extend self

  # start all tunnels
  def start_all
    Pipe2me::Procfile.write      # rebuild procfile

    puts File.read(Pipe2me::Procfile.path)
    Dir.chdir Pipe2me::Config.path
    Kernel.exec "./pipe2me-runner"
  end
end
