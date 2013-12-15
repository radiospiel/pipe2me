require "shell_format"
require "sinatra/json"

class Controllers::Subdomains < Controllers::Base
  set :sourcefile, __FILE__

  helpers ::ShellFormat
  helpers Sinatra::JSON

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
    subdomain = Subdomain.create!
    shell public_attributes(subdomain)
  end

  # -- show: get an individual subdomain --------------------------------------

  # return the token configuration
  get "/:token" do
    subdomain = Subdomain.find_by_token(params[:token])
    shell public_attributes(subdomain)
  end

  get "/:token/id_rsa" do
    subdomain = Subdomain.find_by_token(params[:token])
    content_type :text
    subdomain.ssh_keygen!
    subdomain.ssh_private_key
  end

  get "/:token/id_rsa.pub" do
    subdomain = Subdomain.find_by_token(params[:token])
    content_type :text
    subdomain.ssh_keygen!
    subdomain.ssh_public_key
  end

  private

  def public_attributes(subdomain)
    {
      token:            subdomain.token,
      ports:            subdomain.ports,
      port:             subdomain.port,
      name:             subdomain.name,
      url:              subdomain.url,
      tunnel:           subdomain.tunnel_private_url
    }
  end
end
