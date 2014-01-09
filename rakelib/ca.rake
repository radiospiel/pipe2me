namespace :ca do
  desc "Create etc/nginx.conf"
  task :init => :localhost do
    system "#{ROOT}/ca/init"

    puts "Initialized ca"
  end

  task :localhost => "var/openssl/private/localhost.pem"
  file "var/openssl/private/localhost.pem" do
    system "#{ROOT}/ca/mk-certificate localhost"
  end
end
