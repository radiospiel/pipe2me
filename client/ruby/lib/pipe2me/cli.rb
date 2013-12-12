#!/usr/bin/env ruby
$:.unshift "."
require "trollop"

module Pipe2me::CLI
  extend self

  def self.load_commands
    Dir.glob("#{File.dirname(__FILE__)}/cli/*.rb").each do |file|
      load file
    end
  end

  def self.commands
    @commands ||= begin
      self.load_commands
      public_instance_methods.map(&:to_s)
    end
  end
end

global_opts = Trollop::options do
  banner <<-BANNER
pipe2.me command line client.

  pipe2me [ <options> ] <subcommand> [ <options> ]

where <subcommand> can be one of

  install ... install pipe2me dependencies and OS scripts
  setup   ... setup pipe2me tunnel
  enable  ... enable all pipe2me tunnels
  disable ... disable all pipe2me tunnels
  status  ... print pipe2me tunnel status

Options include:

  BANNER

  # opt :dry_run, "Don't actually do anything", :short => "-n"
  stop_on Pipe2me::CLI.commands
end

cmd = ARGV.shift
unless Pipe2me::CLI.commands.include?(cmd)
  Trollop::die "Unknown or missing subcommand#{" #{cmd.inspect}" if cmd}"
end

cmd_opts = Trollop::options do
  case cmd
  when "setup"
    banner <<-BANNER
setup pipe2me installation.

pipe2me setup [ options ]

    BANNER

    opt :server,  "Use pipe2.me server on that host", :default => "https://pipe2.me:5000"
    opt :auth,    "pipe2.me auth token",  :type => String, :required => true
    opt :port,    "localhost port number", :default => 33411
  end
end

options = global_opts.update(cmd_opts)
Pipe2me.server = options[:server]
UI.warn "Server", Pipe2me.server

begin
  Pipe2me::CLI.send cmd, *ARGV, options
rescue RuntimeError, SystemCallError
  UI.error $!.message
  exit 1
# rescue StandardError
#   STDERR.puts $!.message
#   exit 99
end