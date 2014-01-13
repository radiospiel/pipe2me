require "shell_format"
require "sinatra/json"

class Controllers::Subdomains < Controllers::Base
  set :sourcefile, __FILE__

  helpers ::ShellFormat
  helpers Sinatra::JSON

  before do
    content_type :text
  end

  # -- index: get all subdomains ----------------------------------------------

  get "/" do
    index
  end

  get "/all" do
    index
  end

  def index
    subdomains = Subdomain.all
    shell subdomains: subdomains.map(&:token)
  end

  # -- return the root certificate --------------------------------------------

  get "/:auth/cacert" do
    headers["Content-Type"] = "text/plain"
    File.read "#{VAR}/openssl/root/certificate.pem"
  end

  # -- create: create a new subdomain -----------------------------------------

  post "/:auth" do
    case auth = params[:auth]
    when "test@test.kinko.me", "review@test.kinko.me"
      protocols = params[:protocols] || "http"
      subdomain = Subdomain.create! protocols: protocols.split(",")
      shell public_attributes(subdomain)
    else
      status 403
      "Not allowed"
    end
  end

  # -- show: get an individual subdomain --------------------------------------

  # return the token configuration
  get "/:token" do
    shell public_attributes(subdomain)
  end

  post "/:token/id_rsa.pub" do
    id_rsa_pub = request.body.read.to_s
    subdomain.add_ssh_key id_rsa_pub
    "OK"
  end

  get "/:token/cert.pem" do
    # subdomain.openssl_certgen!
    subdomain.openssl_certificate
  end

  post "/:token/cert.pem" do
    csr = request.body.read.to_s
    subdomain.openssl_sign_certificate! csr
    subdomain.openssl_certificate
  end

  private

  def subdomain
    @subdomain ||= (params[:token] && Subdomain.where(token: params[:token]).first) ||
      Subdomain.find(params[:token])
  end

  def public_attributes(subdomain)
    {
      token:            subdomain.token,
      fqdn:             subdomain.fqdn,
      urls:             subdomain.urls,
      tunnel:           subdomain.tunnel_private_url
    }
  end
end
