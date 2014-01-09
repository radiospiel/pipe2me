namespace :init_d do
  desc "Create and install init.d file"
  task :configure do
    require_relative "erb_ext"

    user = `whoami`.chomp
    init_d = "var/init.d/#{user}"
    ERB.process "config/init_d.erb" => init_d
    FileUtils.chmod 0755, init_d

    puts <<-TXT
Copy the init.d script into /etc/init.d via

    sudo cp #{init_d} /etc/init.d/#{user}

and start the services via

    sudo /etc/init.d/#{user} start

To make sure the service starts automatically after a reboot, please run

    sudo update-rc.d #{user} defaults

    TXT
  end
end
