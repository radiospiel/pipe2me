namespace :ca do
  desc "Initialise CA and generate certificate for this server instance"
  task :init => "var/openssl/private/localhost.pem"

  file "var/openssl/private/localhost.pem" do
    miniCA="#{ROOT}/vendor/miniCA/bin/miniCA"

    system "#{miniCA} init -r #{VAR}/miniCA"
    FileUtils.mkdir_p "var/openssl/private"

    Dir.chdir "var/openssl/private" do
      system "#{miniCA} generate localhost"
      system "#{miniCA} sign -r #{ROOT}/var/miniCA localhost.csr"
    end
  end
end
