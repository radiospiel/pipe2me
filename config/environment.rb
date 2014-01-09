# The pipe2me version number.
VERSION = "0.1.0"

# Note: there is an issue with Dotenv, where an existing .env file overrides
# any settings in an explicitely stated configuration file. Therefore we cannot
# use .env AND have a specific configuration file. We use ruby plain instead.

begin
  config = File.expand_path("~/pipe2me.server.conf")
  load config if File.exists?(config)
end
load "config/defaults.rb"

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
