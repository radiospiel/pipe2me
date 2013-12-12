UI.verbosity = 2

module Pipe2me::CLI
  # sets up a pipe2.me tunnel. Options include:
  #
  # - auth: the authtoken, as read from https://pipe2.me/account
  # - port: the port number
  #
  # This method does the following:
  #
  # - fetches a domain name from https://api.pipe2.me
  # - receives SSL certificates for this instance
  # - creates a certificate for the received domain name
  # - creates a CSR for the certificate
  # - sends the CSR to https://api.pipe2.me
  # - receives the certificate
  # - stores everything in /etc/pipe2me
  def setup(options = {})
    response = HTTP.get! "#{Pipe2me.server}/subdomains"
    subdomains = response.parse["subdomains"]
    UI.success "#{Pipe2me.server} has #{subdomains.count} subdomains"

    if Dir.exist?(".pipe2me")
      info_inc = File.read ".pipe2me/subdomain/info.inc"

      if info_inc =~ /TOKEN=(.*)/
        token = $1
      end
      if info_inc =~ /URL=(.*)/
        url = $1
      end

      raise "Invalid config file .pipe2me/subdomain/info.inc" unless token && url
      UI.success "configured tunnel", url
      # if we have a pipe2me setup in this directory, we use that.
    else
      # create a pipe2me setup
      response = HTTP.post! "#{Pipe2me.server}/subdomains", ""
      subdomain = response.parse["subdomain"]
      token, url = subdomain.values_at "token", "url"
      UI.success "created tunnel", url
    end

    response = HTTP.get! "#{Pipe2me.server}/subdomains/#{token}.tar"
    UI.debug "Got provisioning: #{response.bytesize} bytes"

    Tar.extract StringIO.new(response), target: ".pipe2me"
  end
end

