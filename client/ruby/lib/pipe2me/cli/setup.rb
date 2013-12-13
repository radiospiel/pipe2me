require "forwardable"

module Pipe2me::CLI
  extend Forwardable
  delegate :tunnels => Pipe2me::Config

  def list(options = {})
    tunnels.each do |name, tunnel|
      puts name
    end
  end

  # update all tunnels
  def update(options = {})
    tunnels.each do |name, tunnel|
      UI.warn name, tunnel
    end
  end

  # fetch a new pipe2me setup
  #
  # pipe2me setup --server https://pipe2.me:4488 --auth authtoken [ --local 127.0.0.1:123 ]
  def setup(options = {})
    UI.warn "Connecting to #{Pipe2me.server}"

    response = HTTP.post! "#{Pipe2me.server}/subdomains", ""
    subdomain = response.parse["subdomain"]
    token, url = subdomain.values_at "token", "url"
    UI.success "created tunnel", url

    response = HTTP.get! "#{Pipe2me.server}/subdomains/#{token}.tar"
    info = install_response(response)

    UI.debug "#{info[:url]}: Received provisioning #{response.bytesize} bytes"
    puts info[:url]
  end

  private

  # unpacks the tunnel response from the server, returns the tunnel information.
  def install_response(response)
    Dir.mktmpdir("pipe2me") do |dir|
      Tar.extract StringIO.new(response), target: dir

      Dir.glob("#{dir}/subdomain/*").each do |path|
        next unless File.directory?(path)
        FileUtils.mv path, Pipe2me::Config.dir(:tunnels)
      end

      Pipe2me::Config.parse_info "#{dir}/subdomain/info.inc"
    end
  end
end
