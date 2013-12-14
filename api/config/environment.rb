# -- configure subdomains -----------------------------------------------------

# The pipe2me version number.

VERSION = "0.1.0"

# # The control interface and port, e.g. 0.0.0.0:4444
TUNNEL_CONTROL_PORT = '127.0.0.1:4444'
TUNNEL_USER = `whoami`.chomp

#
# Manage subdomains of these domains:
DOMAIN = "pipe2.dev"

# Manage these ports:
PORTS = 10000...40000

# How many ports per subdomain? Each subdomain gets the same number of ports.
# NOTE: THIS VALUE CANNOT BE CHANGED!
PORTS_PER_SUBDOMAIN = 1

ROOT=File.expand_path "#{File.dirname(__FILE__)}/../"
STDERR.puts "Starting app in #{ROOT}"

$: << "#{ROOT}/app"
$: << "#{ROOT}/lib"

RACK_ENV = ENV["RACK_ENV"] || "development"
DATABASE_URL="sqlite3:///#{ROOT}/var/#{RACK_ENV}.sqlite3"

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

