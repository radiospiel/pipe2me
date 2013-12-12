class Controllers::Subdomains < Controllers::Base
  set :sourcefile, __FILE__

  before do
    self.default_renderer = :json
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
    attrs = subdomains.map { |subdomain| render_attributes(subdomain) }
    render subdomains: attrs
  end

  # -- create: create a new subdomain -----------------------------------------

  post "/:auth" do
    subdomain = Subdomain.create!
    render subdomain: render_attributes(subdomain)
  end

  post "/" do
    subdomain = Subdomain.create!
    render subdomain: render_attributes(subdomain)
  end

  # -- show: get an individual subdomain --------------------------------------

  # return the token configuration
  get "/:token" do
    subdomain = Subdomain.find_by_token(params[:token])
    render subdomain: render_attributes(subdomain)
  end

  private

  def render_attributes(subdomain)
    attrs = {
      token:            subdomain.token,
      ports:            subdomain.ports,
      port:             subdomain.port,
      name:             subdomain.name,
      url:              subdomain.url
    }

    if auto_renderer == :tar
      subdomain.ssh_keygen!

      attrs = {
        "info.inc"      => shell(attrs),
        subdomain.fullname => {
          "info.inc"    => shell(attrs),
          "id_rsa"      => subdomain.ssh_private_key,
          "id_rsa.pub"  => subdomain.ssh_public_key
        }
      }
    end

    attrs
  end
end
