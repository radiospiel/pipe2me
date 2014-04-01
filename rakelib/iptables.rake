# iptables code. Works only on linux, and requires "sudo /sbin/iptables" to
# run without a password.
namespace :iptables do
  task :setup do
    require "iptables"
    IPTables.setup
  end

  task :report do
    require "iptables"
    IPTables.report
  end
end
