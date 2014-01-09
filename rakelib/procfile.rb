module Procfile
  def self.each_group(path)
    File.readlines("Procfile").grep(/^[^#]*[a-zA-Z]/).each do |line|
      line.chomp!
      name, cmd = line.split(/:\s*/, 2)
      yield name, cmd
    end
  end

  def self.each(path, options = {})
    port = options[:port] || 5555

    each_group path do |name, cmd|
      concurrency = options[name.to_sym] || 1

      1.upto(concurrency).each do |idx|
        yield name, "#{name}#{idx}", cmd, port+idx-1
      end

      port += 100
    end
  end
end
