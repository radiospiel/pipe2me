class Controllers::Inspect < Controllers::Base

  helpers do
    def format_hash(hsh)
      hsh.sort_by(&:first).
        map { |key, value| "%25s: %s\n" % [ key.to_s, value.inspect ] }.
        join
    end
  end

  get "/" do
    headers["Content-Type"] = "text/plain"

    [
      "# Request\n\n",
      format_hash(request_method: request.request_method,
                        fullpath: request.fullpath,
                        port: request.port,
                        scheme: request.scheme,
                        host_with_port: request.host_with_port),
      "\n# Headers\n\n",
      format_hash(headers),
      "\n# Request env\n\n",
      format_hash(request.env.select { |key,v| key !~ /[a-z]/ })
    ]
  end
end
