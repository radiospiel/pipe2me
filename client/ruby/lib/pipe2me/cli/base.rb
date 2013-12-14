module Pipe2me::CLI
  SELF = self
  extend self

  def self.commands
    @commands ||= {}
  end

  def self.command_names
    commands.keys
  end

  def self.method_added(method_name)
    commands[method_name.to_s] = { banner: @banner, opts: @opts }

    @banner = @opts = nil
  end

  # subcommand options
  def self.banner(banner)
    @banner = banner
  end

  def self.option(*args)
    @opts ||= []
    @opts << args
  end

  attr :options, true

  def self.subcommand(cmd, global_options)
    banner, opts = commands[cmd.to_s].values_at :banner, :opts

    banner_opts = "[ options ] " if opts

    m = self.method(cmd)
    if m.arity > 0
      banner_args = "<arg> " * m.arity
    elsif m.arity < 0
      banner_args = "<arg> " * (-m.arity-1)
      banner_args += "[ <arg> .. ]"
    end

    cmd_opts = Trollop::options do
      self.banner "pipe2me #{cmd} #{banner_opts}#{banner_args}\n\n#{banner}\n "
      if opts
        self.banner "Options include:\n "
      end

      (opts || []).each do |sym, *args|
        opt sym, *args
      end
    end

    self.options = global_options.update(cmd_opts)
    self.send cmd, *ARGV
  end

  # run
  def self.run(b, &block)
    overview = commands.
      select  do |name, trollops| trollops[:banner] end.
      map     do |name, trollops| "%11s ... %s\n" % [ name, trollops[:banner] ] end.
      join

    options = Trollop::options do
      self.banner "#{b}\n\n  pipe2me [ <options> ] <subcommand> [ <options> ]\n "
      self.banner "where <subcommand> can be one of\n\n#{overview} "

      self.banner "Options include:\n "

      opt :verbose, "Be verbose"
      opt :quiet, "Be quiet"
      opt :silent, "Be silent"

      instance_eval(&block) if block

      stop_on SELF.command_names
    end

    # -- determine UI verbosity -----------------------------------------------

    if options[:verbose]    then UI.verbosity = 3
    elsif options[:quiet]   then UI.verbosity = 0
    elsif options[:silent]  then UI.verbosity = -1
    else                         UI.verbosity = 2
    end

    UI.colored = false if UI.verbosity <= 0

    # -- run subcommand -------------------------------------------------------

    cmd = ARGV.shift
    unless command_names.include?(cmd)
      Trollop::die "Unknown or missing subcommand#{" #{cmd.inspect}" if cmd}"
    end

    subcommand cmd, options
  end
end
