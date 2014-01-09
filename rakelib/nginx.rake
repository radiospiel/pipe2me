namespace :nginx do
  desc "Create var/config/nginx.conf"
  task :configure => "ca:init" do
    require_relative "erb_ext"

    FileUtils.cp_r "config/nginx", "var/config"
    ERB.process "config/nginx.conf.erb" => "var/config/nginx.conf"
  end
end
