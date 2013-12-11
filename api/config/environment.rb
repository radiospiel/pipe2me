ROOT=File.expand_path "#{File.dirname(__FILE__)}/../"
STDERR.puts "Starting app in #{ROOT}"

$: << "#{ROOT}/app"
$: << "#{ROOT}/lib"

require "models"
