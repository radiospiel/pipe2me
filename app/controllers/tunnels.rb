require "shell_format"
require "sinatra/json"

class Controllers::Tunnels < Controllers::Base
  set :sourcefile, __FILE__

  helpers ::ShellFormat
  helpers Sinatra::JSON

  before do
    content_type :text
  end

  # -- index: get all tunnels ----------------------------------------------

  get "/" do
    index
  end

  get "/all" do
    index
  end

  def index
    tunnels = Tunnel.all
    shell tunnels: tunnels.map(&:token)
  end

  # -- return the root certificate --------------------------------------------

  get "/:auth/cacert" do
    headers["Content-Type"] = "text/plain"
    File.read "#{VAR}/openssl/root/certificate.pem"
  end

  # -- create: create a new tunnel -----------------------------------------

  post "/:auth" do
    case auth = params[:auth]
    when "test@test.kinko.me", "review@test.kinko.me"
      protocols = params[:protocols] || "http"
      tunnel = Tunnel.create! protocols: protocols.split(",")
      shell public_attributes(tunnel)
    else
      status 403
      "Not allowed"
    end
  end

  # -- show: get an individual tunnel --------------------------------------

  # return the token configuration
  get "/:token" do
    shell public_attributes(tunnel)
  end

  post "/:token/id_rsa.pub" do
    id_rsa_pub = request.body.read.to_s
    tunnel.add_ssh_key id_rsa_pub
    "OK"
  end

  get "/:token/cert.pem" do
    tunnel.openssl_certificate
  end

  post "/:token/cert.pem" do
    csr = request.body.read.to_s
    tunnel.openssl_sign_certificate! csr
    tunnel.openssl_certificate
  end

  private

  def tunnel
    @tunnel ||= (params[:token] && Tunnel.where(token: params[:token]).first) ||
      Tunnel.find(params[:token])
  end

  def public_attributes(tunnel)
    {
      token:            tunnel.token,
      fqdn:             tunnel.fqdn,
      urls:             tunnel.urls,
      tunnel:           tunnel.tunnel_private_url
    }
  end
end
