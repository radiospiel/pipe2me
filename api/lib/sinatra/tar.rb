require "rubygems/package"

Gem::Package::TarWriter
class Gem::Package::TarWriter
  def add_entry(name, data, options = {}) #:nodoc:
    check_closed

    name, prefix = split_name name

    tar_options = options.merge(:name => name, :size => data.bytesize, :prefix => prefix)
    header = Gem::Package::TarHeader.new(tar_options)
    @io.write header
    @io.write data

    self
  end
end

# The Sinatra::Shell helper formats a hash as a tar file.
module Sinatra::Tar
  SELF=self
  
  def self.add_tar_entries(tar, entries, options = {})
    prefix = options[:prefix]
    
    entries.each do |key, value|
      key = key.to_s
      path = options[:prefix] ? File.join(options[:prefix].to_s, key) : key

      case value
      when Hash
        add_tar_entries tar, value, :prefix => path
      when nil
      else
        tar.add_entry path, value.to_s, mode: 0644, mtime: Time.now
      end
    end
  end

  def tar(entries)
    raise ArgumentError, "Invalid entries: #{entries.inspect}" unless entries.is_a?(Hash)
    headers["Content-Type"] = "application/x-tar"

    s = ""
    Gem::Package::TarWriter.new(StringIO.new(s)) do |tar|
      SELF.add_tar_entries tar, entries, prefix: nil
    end
    s
  end
end
