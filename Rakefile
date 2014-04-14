require "sinatra/activerecord/rake"

if ENV["SIMPLE_COV"] == "1"
  require "simplecov"
  SimpleCov.start do
    add_filter "test/*"
    add_filter "rakelib/*"
    add_filter "config/*"
  end
end

require_relative "config/environment"

task :configure => "configure:dependencies"
task :configure => "configure:directories"
task :configure => "configure:files"
task :configure => "db:migrate"

task :configure => "nginx:configure"
task :configure => "sshd:configure"
task :configure => "monit:configure"
task :configure => "redis:configure"

task :default => "test"

task :update do
  # pull updated source
  Sys.sys! "git", "stash"
  Sys.sys! "git", "pull", "--rebase"
  Sys.sys! "git", "stash", "pop"
  Sys.sys! "bundle", "install"
  Sys.sys! "rake", "db:migrate", "configure"
  Sys.sys! "whenever", "--update-crontab"
end

namespace :run do
  task :check do
    ActiveRecord::Base.logger.level = Logger::INFO
    while true do
      sleep 1
      UI.success "check"
      MetricSystem.count
      Tunnel.check do
        SSHD.write_authorized_keys
      end
      Tunnel.ancient.destroy_all
    end
  end
end

desc "Start the pipe2me server"
task :start => "configure" do
  system "monit -c monitrc && monit -c monitrc start all"
end

desc "Stop the pipe2me server"
task :stop do
  system "monit -c monitrc stop all && monit -c monitrc quit"
end

desc "Restart the pipe2me server"
task :restart do
  system "monit -c monitrc stop all && monit -c monitrc reload && monit -c monitrc start all"
end
