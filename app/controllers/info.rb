require "shell_format"

class Controllers::Info < Controllers::Base
  helpers ShellFormat

  set :sourcefile, __FILE__

  helpers do
    def url_base
      if HTTPS_PORT
        "https://#{request.host}:#{HTTPS_PORT}"
      else
        "#{request.scheme}://#{request.host_with_port}"
      end
    end

    def openssl_fingerprint(file, mode = :md5)
      expect! mode => [ :md5, :sha1 ]
      `openssl x509 -noout -fingerprint -#{mode} -in #{file}`.chomp
    end

    def pipe2me_config
      {
        domain:       TUNNEL_DOMAIN,
        environment:  RACK_ENV,
        ports:        TUNNEL_PORTS,
        version:      VERSION,
        url:          url_base
      }
    end
  end

  get "/" do
    headers["Content-Type"] = "text/plain"

    erb :info
  end

  get "/cacert" do
    headers["Content-Type"] = "application/x-x509-ca-cert"
    File.read("var/miniCA/root.pem")
  end

  get "/config" do
    json pipe2me_config
  end

  # get "/auth" do
  #   json(
  #     auth: "auth"
  #   )
  # end
end
