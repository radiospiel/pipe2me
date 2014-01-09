namespace :nginx do
  desc "Create etc/nginx.conf"
  task :configure => "ca:init" do
    nginx_conf_file = "config/nginx.conf"
    erb = ERB.new File.read("config/nginx.conf.erb")

    File.open nginx_conf_file, "w" do |io|
      io.write erb.result
    end

    puts "Created #{nginx_conf_file}"
  end
end
