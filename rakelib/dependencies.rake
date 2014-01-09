require_relative "./rake-install"

namespace :install do
  desc "Install dependencies"
  packages :dependencies, "daemon", "monit", "sshd"
  packages :dependencies, "daemon"
  packages :dependencies, "nginx"
  packages :dependencies, "openssl"
  # packages :dependencies, "sslh"

  namespace :darwin do
    binary "sshd"
    brew "daemon", "monit", "nginx", "sslh"
    binary "openssl"
  end

  namespace :debian do
    binary "sshd" => "/usr/sbin/sshd"
    binary "openssl"

    apt "nginx" => "/usr/sbin/nginx"
    apt "daemon"
    apt "monit"
    apt "sslh"
  end
end
