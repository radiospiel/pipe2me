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

task :default => "test"

namespace :run do
  task :check do
    ActiveRecord::Base.logger.level = Logger::INFO
    while true do
      sleep 5
      UI.success "check"
      Tunnel.check do
        SSHD.write_authorized_keys
      end
      Tunnel.ancient.destroy_all
    end
  end
end

desc "Start the pipe2me server"
task :start do
  Kernel.exec "bash", "-c", "monit -c monitrc && monit -c monitrc start all"
end

desc "Stop the pipe2me server"
task :stop do
  Kernel.exec "bash", "-c", "monit -c monitrc stop all && monit -c monitrc quit"
end

desc "Restart the pipe2me server"
task :restart do
  Kernel.exec "bash", "-c", "monitrc stop all && monit -c monitrc reload && monit -c monitrc start all"
end
