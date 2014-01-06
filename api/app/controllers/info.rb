class Controllers::Info < Controllers::Base
  get "/" do
    headers["Content-Type"] = "text/plain"
    "pipe2me API #{VERSION}"
  end

  get "/cacert" do
    headers["Content-Type"] = "text/plain"
    File.read "#{VAR}/openssl/root/certificate.pem"
  end

  get "/version" do
    render(
      api: "pipe2me #{VERSION}",
      version: VERSION,
      domain: TUNNEL_DOMAIN,
      ports: TUNNEL_PORTS
    )
  end
end

