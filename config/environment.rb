# The pipe2me version number.
VERSION = "0.1.0"

require "simple/ui"

# -- path settings ------------------------------------------------------------

ROOT=File.expand_path "#{File.dirname(__FILE__)}/../"

RACK_ENV = ENV["RACK_ENV"] || "development"
if RACK_ENV == "test"
  VAR=File.join "#{ROOT}/var-test"
else
  VAR=File.join "#{ROOT}/var"
end

# -- does VAR exist? ----------------------------------------------------------

unless File.exists?(VAR)
  system "mkdir -p ~/pipe2me.#{File.basename VAR}"
  system "ln -sf ~/pipe2me.#{File.basename VAR} #{File.basename VAR}"
  UI.success "Created and linked ~/pipe2me.#{File.basename VAR}"
end

# -- set ruby search path -----------------------------------------------------

$: << "#{ROOT}/app"
$: << "#{ROOT}/app/models"
$: << "#{ROOT}/lib"

# -- load initializers --------------------------------------------------------

Dir.glob("#{ROOT}/config/initializers/*.rb").sort.each do |file|
  load file
end

# -- load models --------------------------------------------------------------

require "active_record"
I18n.enforce_available_locales = false

require "models/tunnel"

# -- initialize models --------------------------------------------------------

# we must load the controllers/base file to make sure that the database
# is actually connected. Yes, that sounds weird, but this is how
# sinatra-active_record works (and we need this only for rake tasks anyway.)
require "controllers/base"
