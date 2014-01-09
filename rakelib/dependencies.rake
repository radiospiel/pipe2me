require_relative "./rake-install"

namespace :install do
  desc "Install dependencies"
  packages :dependencies, "daemon", "monit", "sshd"
  packages :dependencies, "daemon", "tt"

  namespace :darwin do
    binary "sshd"
    brew "daemon", "monit", "nginx", "tt"
    task "tt" => :nginx
  end

  namespace :debian do
    binary "sshd"
    apt "daemon", "monit", "nginx", "tt"
    task "tt" => :nginx
  end
end
