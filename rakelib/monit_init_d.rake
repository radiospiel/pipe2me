namespace :monit do
  desc "Create and install init.d file"
  task :install => [:monitrc, :install_init_d]

  task :install_init_d do
    user = `whoami`.chomp
    init_d = "var/#{user}.init_d"
    File.open init_d, "w" do |io|
      src = File.read(__FILE__).split(/__END__\s+/).last
      io.write ERB.new(src).result
    end

    FileUtils.chmod 0755, init_d

    puts <<-TXT
Created file #{init_d}. Copy it into /etc/init.d via

    sudo cp #{init_d} /etc/init.d/#{user}

and start the services via

    sudo /etc/init.d/#{user} start

To make sure the service starts automatically after a reboot, please run

    sudo update-rc.d kinko defaults

    TXT
  end
end

__END__

#!/bin/sh
### BEGIN INIT INFO
# Provides:          <%= `whoami`.chomp %>
# Required-Start:
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: The <%= `whoami`.chomp %> process group
### END INIT INFO

set -e

USER=<%= `whoami`.chomp %>
MONIT=monit

export PATH="${PATH:+$PATH:}/usr/sbin:/sbin:/usr/bin"

case "$1" in
  start)
    echo -n "Starting monit services: "$USER
    su - $USER bash -c $MONIT start all
    echo "."
  ;;
  stop)
    echo -n "Stopping monit services: "$USER
    su - $USER bash -c $MONIT stop all
    echo "."
  ;;
  restart)
    echo -n "Restarting monit services: "$USER
    su - $USER bash -c $MONIT restart all
    echo "."
  ;;
  status)
    su - $USER bash -c $MONIT status
  ;;
  *)
    echo "Usage: "$0" {start|stop|restart|status}"
    exit 1
esac

exit 0
