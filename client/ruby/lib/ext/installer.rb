require "ext/sys"

module Installer
  extend self

  def install(*binaries)
    missing_binaries = binaries.reject do |name|
      which(name)
    end

    return true if missing_binaries.empty?

    raise "The following binaries are missing or not in your path: #{missing_binaries.join(", ")}"
  end

  def which(binary)
    return unless path = Sys.sys("which", binary)

    path.chomp!
    STDERR.puts "Using #{binary} in #{path}."
    path
  end

  def which!(binary)
    which(binary) || raise("The following binary is missing or not in your path: #{binary}")
  end
end
