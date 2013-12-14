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

    return true if missing_binaries.empty?

    UI.error "The following binaries are missing or not in your path", *missing_binaries
    false
  end

  def which(binary)
    return unless path = Sys.sys("which", binary)
    path.chomp!
  end
end
