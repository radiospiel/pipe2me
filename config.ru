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

if ENV["STATHAT_EMAIL"]
  require "rack/stathat"
  use Rack::Stathat, :ez_api_key => ENV["STATHAT_EMAIL"], :prefix => ENV["STATHAT_PREFIX"]
else
  STDERR.puts "To report requests to stathat set the STATHAT_EMAIL and STATHAT_PREFIX environment values"
end

require "sinatra/base"

if Sinatra::Base.development?
  use Rack::Lint
end

use Rack::Static, :urls => ["/assets"], :root => 'public'

unless Sinatra::Base.development?
  use Rack::CommonLogger
end

# -- redirect on tunnel name --------------------------------------------------

require "models/tunnel/redirection"
use Tunnel::Redirection

# -- more rack stuff ----------------------------------------------------------

use Rack::ETag
use Rack::ContentLength

# -- load session_key ---------------------------------------------------------

use Rack::Session::Cookie, :secret => File.secret("#{VAR}/rack.session_key")

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
require "controllers/tunnels"

# -- run app ------------------------------------------------------------------

run Rack::URLMap.new(
  "/"               => Controllers::Info.new,
  "/tunnels"        => Controllers::Tunnels.new
)
