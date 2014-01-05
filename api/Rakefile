require "sinatra/activerecord/rake"
require_relative "config/environment"

namespace :sshd do
  desc "Start sshd server non-daemonized"
  task :exec do
    require "sshd"
    SSHD.exec
  end
end

desc "Install dependencies"
task "dependencies:install" do
end
