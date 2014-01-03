require 'dotenv'
Dotenv.load

# The pipe2me version number.
VERSION = "0.1.0"

# -- tunnel configuration -----------------------------------------------------

# TUNNEL_DOMAIN: Manage subdomains of this domain
# TUNNEL_PORTS: Port range for public tunnel endpoint, e.g. "10000...12000"

TUNNEL_DOMAIN = ENV["TUNNEL_DOMAIN"] || "pipe2.dev"

port_range = ENV["TUNNEL_PORT_RANGE"] || "10000...40000"
raise ArgumentError, "Invalid TUNNEL_PORT_RANGE setting: #{port_range.inspect}" unless port_range =~ /^(\d+)...(\d+)$/
TUNNEL_PORTS = $1.to_i ... $2.to_i

# -- path settings ------------------------------------------------------------

ROOT=File.expand_path "#{File.dirname(__FILE__)}/../"
RACK_ENV = ENV["RACK_ENV"] || "development"

if RACK_ENV == "test"
  VAR=File.join "#{ROOT}/var-test"
else
  VAR=File.join "#{ROOT}/var"
end

$: << "#{ROOT}/app"
$: << "#{ROOT}/app/models"
$: << "#{ROOT}/lib"

# -- load initializers --------------------------------------------------------

Dir.glob("#{ROOT}/config/initializers/*.rb").sort.each do |file|
  load file
end

# -- load models --------------------------------------------------------------

require "active_record"
require "models/subdomain"

# we must load the controllers/base file to make sure that the database
# is actually connected. Yes, that sounds weird, but this is how
# sinatra-active_record works (and we need this only for rake tasks anyway.)
require "controllers/base"
