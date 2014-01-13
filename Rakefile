require "sinatra/activerecord/rake"
require_relative "config/environment"

task :configure => "install:dependencies"
task :configure => "db:migrate"

task :configure => "var/config"
directory "var/config"

task :configure => "nginx:configure"
task :configure => "sshd:configure"
task :configure => "monit:configure"

task :default => "test"
