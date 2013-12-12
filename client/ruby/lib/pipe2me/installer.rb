require "ext/sys"

module Installer
  extend self

  def install(*binaries)
    missing_binaries = binaries.reject do |name|
      if path = which(name)
        STDERR.puts "Using #{name} in #{path}."
      end
      path
    end

    missing_binaries.each do |name|
      installer.send(name)
    end

    puts "installing #{binary}"
  end

  def installer
    @installer ||= OSX
  end

  module OSX
  end

  def which(binary)
    return unless path = Sys.sys("which", binary)
    path.chomp!
  end
end
