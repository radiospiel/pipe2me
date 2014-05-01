namespace :ca do
  desc "Initialise CA and generate certificate for this server instance"
  task :init => "var/openssl/private/localhost.pem"

  file "var/openssl/private/localhost.pem" do
    miniCA="#{ROOT}/vendor/miniCA/bin/miniCA"

    system "#{miniCA} init -r #{VAR}/miniCA"
    FileUtils.mkdir_p "var/openssl/private"

    Dir.chdir "var/openssl/private" do
      Sys.sys! miniCA, :generate, TUNNEL_DOMAIN

      if TUNNEL_DOMAIN != "localhost"
        FileUtils.mv "#{TUNNEL_DOMAIN}.csr", "localhost.csr"
        FileUtils.mv "#{TUNNEL_DOMAIN}.priv", "localhost.priv"
      end

      Sys.sys! miniCA, :sign, "-r", "#{ROOT}/var/miniCA", "localhost.csr"
    end
  end
end
