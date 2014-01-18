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
    shell tunnels: tunnels.map(&:id)
  end

  # -- return the root certificate --------------------------------------------

  get "/:auth/cacert" do
    headers["Content-Type"] = "text/plain"
    File.read "#{VAR}/openssl/root/certificate.pem"
  end

  # -- create: create a new tunnel -----------------------------------------

  post "/:token" do
    protocols = params[:protocols] || "http"
    tunnel = Tunnel.new protocols: protocols.split(","), token: params[:token]

    if tunnel.valid?
      tunnel.save!
      shell public_attributes(tunnel)
    else
      status 403
      "Not allowed: #{tunnel.errors.full_messages.join(", ")}"
    end
  end

  # -- show: get an individual tunnel --------------------------------------

  # return the token configuration
  get "/:id" do
    shell public_attributes(tunnel)
  end

  post "/:id/id_rsa.pub" do
    id_rsa_pub = request.body.read.to_s
    tunnel.add_ssh_key id_rsa_pub
    "OK"
  end

  get "/:id/cert.pem" do
    tunnel.openssl_certificate
  end

  post "/:id/cert.pem" do
    csr = request.body.read.to_s
    tunnel.openssl_sign_certificate! csr
    tunnel.openssl_certificate
  end

  private

  def tunnel
    @tunnel ||= Tunnel.find(params[:id])
  end

  def public_attributes(tunnel)
    {
      id:               tunnel.id,
      fqdn:             tunnel.fqdn,
      urls:             tunnel.urls,
      tunnel:           tunnel.tunnel_private_url
    }
  end
end
