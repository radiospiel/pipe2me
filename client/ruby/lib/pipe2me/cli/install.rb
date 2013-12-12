module Pipe2me::CLI
  # This installs the pipe2me software on Linux and OSX. It also ensures that
  # all dependencies (most notably ssh, autossh) are available,  and that the
  # system is supported. (We support Debian, probably some other Linuxes, and OSX.)
  #
  # Installs the pipe2me init script on Linux. Installs a LaunchAgent on OSX.
  def install(*args)
    # install needed binaries
    Installer.install "ssh", "autossh"

    # install launchagent/init script
    # Installer.install "ssh", "autossh"
  end
end
