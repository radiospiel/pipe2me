class Controllers::Info < Controllers::Base
  get "/" do
    headers["Content-Type"] = "text/plain"
    "pipe2me API #{VERSION}"
  end

  get "/version" do
    render(
      api: "pipe2me #{VERSION}",
      version: VERSION,
      domain: DOMAIN,
      ports: PORTS,
      ports_per_subdomain: PORTS_PER_SUBDOMAIN
    )
  end
end

