require 'dotenv'
Dotenv.load

# -- configuration ------------------------------------------------------------

# The pipe2me version number.

VERSION = "0.1.0"

# Manage subdomains of these domains:
DOMAIN = ENV["DOMAIN"] || "pipe2.dev"

# The control interface and port, e.g. 0.0.0.0:4444
TUNNEL_CONTROL = ENV["TUNNEL_CONTROL"] || "#{DOMAIN}:4444"
TUNNEL_USER    = ENV["TUNNEL_USER"] || `whoami`.chomp

# Manage these ports:
port_range = ENV["TUNNEL_PORT_RANGE"] || "10000...40000"
unless port_range =~ /^(\d+)...(\d+)$/
  raise ArgumentError, "Invalid TUNNEL_PORT_RANGE setting: #{port_range.inspect}"
end

PORTS = $1.to_i ... $2.to_i

# How many ports per subdomain? Each subdomain gets the same number of ports.
# NOTE: THIS VALUE CANNOT BE CHANGED!
PORTS_PER_SUBDOMAIN = Integer(ENV["TUNNEL_PORTS_PER_SUBDOMAIN"] || 1)

# -- start app ----------------------------------------------------------------

ROOT=File.expand_path "#{File.dirname(__FILE__)}/../"
STDERR.puts "Starting app in #{ROOT}"

$: << "#{ROOT}/app"
$: << "#{ROOT}/lib"

RACK_ENV = ENV["RACK_ENV"] || "development"
DATABASE_URL=ENV["DATABASE_URL"] || "sqlite3:///#{ROOT}/var/#{RACK_ENV}.sqlite3"

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
