require "tmpdir"

module Pipe2me::Config
  extend self

  def whoami
    `whoami`.chomp
  end

  attr :dir, true

  def dir(subdir=nil)
    dir = @dir || (whoami == "root" ? "/etc/pipe2me" : File.expand_path("~/.pipe2me"))
    dir = File.join(dir, subdir.to_s) if subdir
  end

  def tunnels
    Dir.glob("#{dir(:tunnels)}/*").sort.inject({}) do |hsh, dirname|
      hsh.update File.basename(dirname) => dirname
    end
  end

  def parse_info(path)
    File.readlines(path).inject({}) do |hsh, line|
      key, value = line.split(/\s*=\s*/, 2)
      hsh.update key.downcase.to_sym => value.gsub(/\s*$/, "")
    end
  end
end
