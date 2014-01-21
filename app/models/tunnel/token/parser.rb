module Tunnel::Token::Parser
  extend self

  # Token defaults
  DEFAULTS = {
    max_ports:  1,
    lifespan:   180,
    extend:     false,
    unique:     false
  }

  # read all known tokens from a file
  def all(path = "#{VAR}/tokens.conf")
    tokens = {}

    File.readlines(path).each_with_index do |line, lineno|
      line.chomp!
      begin
        name, token = parse_line(line)
        tokens[name] = token if name && token
      rescue
        UI.warn "#{path}:#{lineno+1}: #{$!}: #{line.inspect}"
      end
    end

    tokens
  end

  private

  def parse_line(line)
    return if line =~ /^\s*(#|$)/           # a comment

    raise "Invalid entry" if line =~ /=.*=/                 # name = value
    name, values = line.split(/\s+=/, 2)

    token = DEFAULTS.dup

    values.split(/\s+/).each do |entry|
      next if entry == ""
      raise "Invalid entry" if entry =~ /(:.*:)|(^:)|(:$)/

      key, value = entry.split(/:/, 2)

      case value
      when /^\d+$/  then value = Integer(value)
      when "false"  then value = false
      when "true"   then value = true
      end

      token.update key.to_sym => value
    end

    [name, token]
  end
end
