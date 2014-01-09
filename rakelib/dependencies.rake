require_relative "./rake-install"

namespace :install do
  desc "Install dependencies"
  packages :dependencies, "daemon", "monit", "sshd"
  packages :dependencies, "daemon"
  packages :dependencies, "nginx"

  namespace :darwin do
    binary "sshd"
    brew "daemon", "monit", "nginx"
  end

  namespace :debian do
    binary "sshd" => "/usr/sbin/sshd"
    apt "nginx" => "/usr/sbin/nginx"
    apt "daemon"
    apt "monit"
  end
end
