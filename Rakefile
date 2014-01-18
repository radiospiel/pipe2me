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

task :configure => "install:dependencies"
task :configure => "db:migrate"

task :configure => "var/config"
directory "var/config"

task :configure => "nginx:configure"
task :configure => "sshd:configure"
task :configure => "monit:configure"

task :default => "test"
