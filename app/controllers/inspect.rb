class Controllers::Inspect < Controllers::Base

  helpers do
    def format_hash(hash, upcase_only = false)
      hash.to_a.
        sort_by(&:first).map do |key, value|
          next if upcase_only && key =~ /[a-z]/
          "%25s: %s\n" % [ key.to_s, value.inspect ]
        end.compact.
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
      format_hash(request.env, upcase_only: true)
    ]
  end
end
