namespace :sshd do
  desc "Create sshd configuration"
  task :configure => [ :ssh_dir, :hostkey, :authorized_keys ] do
    require_relative "erb_ext"
    ERB.process "config/sshd.conf.erb" => "var/config/sshd.conf"
  end

  task :ssh_dir => "var/sshd"
  directory "var/sshd"

  task :hostkey => "var/sshd/host_key"
  file "var/sshd/host_key" do
    system "ssh-keygen", "-t", "rsa", "-f", "var/sshd/host_key", "-N", ''
  end

  task :authorized_keys => "var/sshd/authorized_keys"
  file "var/sshd/authorized_keys" do |task|
    FileUtils.touch task.name
    STDERR.puts "Created empty #{task.name}"
  end
end

