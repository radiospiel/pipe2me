# -- redirect stdout via timestamp tool ---------------------------------------

# if ENV["RACK_ENV"] != "production"
#   reader, writer = IO.pipe
#   fork do
#     Process.setpgrp
#     STDIN.reopen reader
#     writer.close
#     exec("../../sys/bin/timestamp %X")
#   end
#   STDOUT.reopen writer
#   STDERR.reopen writer
#   reader.close
# end

# -- load app environment -----------------------------------------------------

require "#{File.dirname(__FILE__)}/config/environment"

# -- redirect stdout via timestamp tool ---------------------------------------

require "rack"
require "sinatra/base"

if Sinatra::Base.development?
  use Rack::Lint
end

use Rack::Static, :urls => ["/assets"], :root => 'public'

unless Sinatra::Base.development?
  use Rack::CommonLogger 
end

# -- redirect on subdomain name -----------------------------------------------

require "models/subdomain/redirection"
use Subdomain::Redirection

# -- more rack stuff ----------------------------------------------------------

use Rack::ETag
use Rack::ContentLength

# -- load session_key ---------------------------------------------------------

session_key_path = "#{File.dirname(__FILE__)}/var/rack.session_key"

unless File.exists?(session_key_path)
  FileUtils.mkdir_p File.dirname(session_key_path)
  File.open session_key_path, "w" do |io|
    io.write SecureRandom.base64(16).gsub(/=+$/, "")
  end
end

use Rack::Session::Cookie, :secret => File.read(session_key_path)

# -- CSRF protection ----------------------------------------------------------

require "rack/csrf"

# [todo]
# use Rack::Csrf, :raise => true

# -- method_override ----------------------------------------------------------

# simulate HTTP verbs for restful forms
# use Rack::MethodOverride

# -- load controllers ---------------------------------------------------------

require "controllers"
require "controllers/info"
require "controllers/subdomains"

# -- run app ------------------------------------------------------------------

run Rack::URLMap.new(
  "/"               => Controllers::Info.new,
  "/subdomains"     => Controllers::Subdomains.new
)
