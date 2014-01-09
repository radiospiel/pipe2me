require "sinatra/activerecord/rake"
require_relative "config/environment"

task :configure => "var/config"
directory "var/config"

task :configure => "nginx:configure"
task :configure => "sshd:configure"
task :configure => "monit:configure"
