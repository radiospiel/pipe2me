# -- configure subdomains -----------------------------------------------------

PORTS = 10000...40000
PORTS_PER_SUBDOMAIN = 1


ROOT=File.expand_path "#{File.dirname(__FILE__)}/../"
STDERR.puts "Starting app in #{ROOT}"

$: << "#{ROOT}/app"
$: << "#{ROOT}/lib"

RACK_ENV = ENV["RACK_ENV"] || "development"
DATABASE_URL="sqlite3:///#{ROOT}/var/#{RACK_ENV}.sqlite3"


require "active_record"
require "models/subdomain"

# we must load the controllers/base file to make sure that the database
# is actually connected. Yes, that sounds weird, but this is how 
# sinatra-active_record works (and we need this only for rake tasks anyway.)
require "controllers/base"
