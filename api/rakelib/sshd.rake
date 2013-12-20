require "sshd"

namespace :sshd do
  # -- files and directories
  
  directory SSHD.path(:sshd_dir)

  file SSHD.path(:host_key) => SSHD.path(:sshd_dir) do
    system "ssh-keygen", "-t", "rsa", "-f", SSHD.path(:host_key), "-N", ''
  end

  task :host_key => SSHD.path(:host_key)

  # -- write authorized_keys file for all subdomains.

  desc "Start sshd server non-daemonized"
  task :exec => [ :host_key ] do
    SSHD.write_config
    SSHD.write_authorized_keys

    command = [ "/usr/sbin/sshd", "-D", "-e", "-f", SSHD.path(:sshd_config) ]
    STDERR.puts "Running #{command.join(" ")}"
    Kernel.exec *command
  end
end
