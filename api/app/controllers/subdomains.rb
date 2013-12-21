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

  # -- create: create a new subdomain -----------------------------------------

  post "/:auth" do
    protocols = params[:protocols] || "http"
    subdomain = Subdomain.create! protocols: protocols.split(",")
    shell public_attributes(subdomain)
  end

  # -- show: get an individual subdomain --------------------------------------

  # return the token configuration
  get "/:token" do
    shell public_attributes(subdomain)
  end

  get "/:token/id_rsa" do
    subdomain.ssh_keygen!
    subdomain.ssh_private_key
  end

  get "/:token/id_rsa.pub" do
    subdomain.ssh_keygen!
    subdomain.ssh_public_key
  end

  get "/:token/cert.pem" do
    subdomain.openssl_certgen!
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
