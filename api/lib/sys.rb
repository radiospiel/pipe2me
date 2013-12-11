require "shellwords"

module Sys
  extend self
  
  class ExitError < RuntimeError; end

  def self.log(*args)
    # STDERR.puts args.map(&:shellescape) * " "
  end
  
  def sys!(*args, &block)
    options = args.last.is_a?(Hash) ? args.pop : {}
    stdin = options[:stdin]

    r = nil
    Sys.log *args
    
    IO.popen([*args.map(&:to_s)], 'w+') do |io|
      io.set_encoding("BINARY")

      io.write(stdin) if stdin
      io.close_write

      r = io.read
    end
  
    if $?.exitstatus != 0
      raise ExitError, r
    end
  
    yield r if block
    r
  end

  def sys(*args, &block)
    sys!(*args, &block) || ""
  rescue ExitError
    nil
  end

  def bash!(cmd, &block)
    sys! "bash", "-c", cmd, &block
  end

  def bash(cmd, &block)
    sys "bash", "-c", cmd, &block
  end
end
