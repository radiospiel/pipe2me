namespace :redis do
  desc "Create redis configuration"
  task :configure => [ :redis_dir ] do
    require_relative "erb_ext"
    ERB.process "config/redis.conf.erb" => "var/config/redis.conf"
  end

  task :redis_dir => "var/redis"
  directory "var/redis"
end
